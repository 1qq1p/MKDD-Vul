pragma solidity ^0.4.24;





interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}








contract PlanetCryptoToken is ERC721Full_custom{
    
    using Percent for Percent.percent;
    
    
    
        
    event referralPaid(address indexed search_to,
                    address to, uint256 amnt, uint256 timestamp);
    
    event issueCoinTokens(address indexed searched_to, 
                    address to, uint256 amnt, uint256 timestamp);
    
    event landPurchased(uint256 indexed search_token_id, address indexed search_buyer, 
            uint256 token_id, address buyer, bytes32 name, int256 center_lat, int256 center_lng, uint256 size, uint256 bought_at, uint256 empire_score, uint256 timestamp);
    
    event taxDistributed(uint256 amnt, uint256 total_players, uint256 timestamp);
    
    event cardBought(
                    uint256 indexed search_token_id, address indexed search_from, address indexed search_to,
                    uint256 token_id, address from, address to, 
                    bytes32 name,
                    uint256 orig_value, 
                    uint256 new_value,
                    uint256 empireScore, uint256 newEmpireScore, uint256 now);

    
    address owner;
    address devBankAddress; 
    address tokenBankAddress; 

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier validateLand(int256[] plots_lat, int256[] plots_lng) {
        
        require(planetCryptoUtils_interface.validateLand(msg.sender, plots_lat, plots_lng) == true, "Some of this land already owned!");

        
        _;
    }
    
    modifier validatePurchase(int256[] plots_lat, int256[] plots_lng) {

        require(planetCryptoUtils_interface.validatePurchase(msg.sender, msg.value, plots_lat, plots_lng) == true, "Not enough ETH!");
        _;
    }
    
    
    modifier validateTokenPurchase(int256[] plots_lat, int256[] plots_lng) {

        require(planetCryptoUtils_interface.validateTokenPurchase(msg.sender, plots_lat, plots_lng) == true, "Not enough COINS to buy these plots!");
        

        

        require(planetCryptoCoin_interface.transferFrom(msg.sender, tokenBankAddress, plots_lat.length) == true, "Token transfer failed");
        
        
        _;
    }
    
    
    modifier validateResale(uint256 _token_id) {
        require(planetCryptoUtils_interface.validateResale(msg.sender, msg.value, _token_id) == true, "Not enough ETH to buy this card!");
        _;
    }
    
    
    modifier updateUsersLastAccess() {
        
        uint256 allPlyersIdx = playerAddressToPlayerObjectID[msg.sender];
        if(allPlyersIdx == 0){

            all_playerObjects.push(player(msg.sender,now,0,0));
            playerAddressToPlayerObjectID[msg.sender] = all_playerObjects.length-1;
        } else {
            all_playerObjects[allPlyersIdx].lastAccess = now;
        }
        
        _;
    }
    
    
    struct plotDetail {
        bytes32 name;
        uint256 orig_value;
        uint256 current_value;
        uint256 empire_score;
        int256[] plots_lat;
        int256[] plots_lng;
    }
    
    struct plotBasic {
        int256 lat;
        int256 lng;
    }
    
    struct player {
        address playerAddress;
        uint256 lastAccess;
        uint256 totalEmpireScore;
        uint256 totalLand;
        
        
    }
    

    
    address planetCryptoCoinAddress = 0xa1c8031ef18272d8bfed22e1b61319d6d9d2881b;
    PlanetCryptoCoin_I internal planetCryptoCoin_interface;
    

    address planetCryptoUtilsAddress = 0x19BfDF25542F1380790B6880ad85D6D5B02fee32;
    PlanetCryptoUtils_I internal planetCryptoUtils_interface;
    
    
    
    Percent.percent private m_newPlot_devPercent = Percent.percent(75,100); 
    Percent.percent private m_newPlot_taxPercent = Percent.percent(25,100); 
    
    Percent.percent private m_resalePlot_devPercent = Percent.percent(10,100); 
    Percent.percent private m_resalePlot_taxPercent = Percent.percent(10,100); 
    Percent.percent private m_resalePlot_ownerPercent = Percent.percent(80,100); 
    
    Percent.percent private m_refPercent = Percent.percent(5,100); 
    
    Percent.percent private m_empireScoreMultiplier = Percent.percent(150,100); 
    Percent.percent private m_resaleMultipler = Percent.percent(200,100); 

    
    
    
    uint256 public devHoldings = 0; 


    mapping(address => uint256) internal playersFundsOwed; 




    
    uint256 public tokens_rewards_available;
    uint256 public tokens_rewards_allocated;
    
    
    uint256 public min_plots_purchase_for_token_reward = 10;
    uint256 public plots_token_reward_divisor = 10;
    
    
    
    uint256 public current_plot_price = 20000000000000000;
    uint256 public price_update_amount = 2000000000000;

    uint256 public current_plot_empire_score = 100;

    
    
    uint256 public tax_fund = 0;
    uint256 public tax_distributed = 0;


    
    uint256 public total_land_sold = 0;
    uint256 public total_trades = 0;

    
    uint256 public total_empire_score; 
    player[] public all_playerObjects;
    mapping(address => uint256) internal playerAddressToPlayerObjectID;
    
    
    
    
    plotDetail[] plotDetails;
    mapping(uint256 => uint256) internal tokenIDplotdetailsIndexId; 



    
    mapping(int256 => mapping(int256 => uint256)) internal latlngTokenID_grids;
    mapping(uint256 => plotBasic[]) internal tokenIDlatlngLookup;
    
    
    
    mapping(uint8 => mapping(int256 => mapping(int256 => uint256))) internal latlngTokenID_zoomAll;

    mapping(uint8 => mapping(uint256 => plotBasic[])) internal tokenIDlatlngLookup_zoomAll;


   
    
    constructor() ERC721Full_custom("PlanetCrypto", "PTC") public {
        owner = msg.sender;
        tokenBankAddress = owner;
        devBankAddress = owner;
        planetCryptoCoin_interface = PlanetCryptoCoin_I(planetCryptoCoinAddress);
        planetCryptoUtils_interface = PlanetCryptoUtils_I(planetCryptoUtilsAddress);
        
        

        all_playerObjects.push(player(address(0x0),0,0,0));
        playerAddressToPlayerObjectID[address(0x0)] = 0;
    }

    

    

    function getToken(uint256 _tokenId, bool isBasic) public view returns(
        address token_owner,
        bytes32  name,
        uint256 orig_value,
        uint256 current_value,
        uint256 empire_score,
        int256[] plots_lat,
        int256[] plots_lng
        ) {
        token_owner = ownerOf(_tokenId);
        plotDetail memory _plotDetail = plotDetails[tokenIDplotdetailsIndexId[_tokenId]];
        name = _plotDetail.name;
        empire_score = _plotDetail.empire_score;
        orig_value = _plotDetail.orig_value;
        current_value = _plotDetail.current_value;
        if(!isBasic){
            plots_lat = _plotDetail.plots_lat;
            plots_lng = _plotDetail.plots_lng;
        } else {
        }
    }
    
    

    function taxEarningsAvailable() public view returns(uint256) {
        return playersFundsOwed[msg.sender];
    }

    function withdrawTaxEarning() public {
        uint256 taxEarnings = playersFundsOwed[msg.sender];
        playersFundsOwed[msg.sender] = 0;
        tax_fund = tax_fund.sub(taxEarnings);
        
        if(!msg.sender.send(taxEarnings)) {
            playersFundsOwed[msg.sender] = playersFundsOwed[msg.sender] + taxEarnings;
            tax_fund = tax_fund.add(taxEarnings);
        }
    }

    function buyLandWithTokens(bytes32 _name, int256[] _plots_lat, int256[] _plots_lng)
     validateTokenPurchase(_plots_lat, _plots_lng) validateLand(_plots_lat, _plots_lng) updateUsersLastAccess() public {
        require(_name.length > 4);
        

        processPurchase(_name, _plots_lat, _plots_lng); 
    }
    

    
    function buyLand(bytes32 _name, 
            int256[] _plots_lat, int256[] _plots_lng,
            address _referrer
            )
                validatePurchase(_plots_lat, _plots_lng) 
                validateLand(_plots_lat, _plots_lng) 
                updateUsersLastAccess()
                public payable {
       require(_name.length > 4);
       
        
        uint256 _runningTotal = msg.value;
        uint256 _referrerAmnt = 0;
        if(_referrer != msg.sender && _referrer != address(0)) {
            _referrerAmnt = m_refPercent.mul(msg.value);
            if(_referrer.send(_referrerAmnt)) {
                emit referralPaid(_referrer, _referrer, _referrerAmnt, now);
                _runningTotal = _runningTotal.sub(_referrerAmnt);
            }
        }
        
        tax_fund = tax_fund.add(m_newPlot_taxPercent.mul(_runningTotal));
        
        
        
        if(!devBankAddress.send(m_newPlot_devPercent.mul(_runningTotal))){
            devHoldings = devHoldings.add(m_newPlot_devPercent.mul(_runningTotal));
        }
        
        
        

        processPurchase(_name, _plots_lat, _plots_lng);
        
        calcPlayerDivs(m_newPlot_taxPercent.mul(_runningTotal));
        
        if(_plots_lat.length >= min_plots_purchase_for_token_reward
            && tokens_rewards_available > 0) {
                
            uint256 _token_rewards = _plots_lat.length / plots_token_reward_divisor;
            if(_token_rewards > tokens_rewards_available)
                _token_rewards = tokens_rewards_available;
                
                
            planetCryptoCoin_interface.transfer(msg.sender, _token_rewards);
                
            emit issueCoinTokens(msg.sender, msg.sender, _token_rewards, now);
            tokens_rewards_allocated = tokens_rewards_allocated + _token_rewards;
            tokens_rewards_available = tokens_rewards_available - _token_rewards;
        }
    
    }
    
    

    function buyCard(uint256 _token_id, address _referrer) validateResale(_token_id) updateUsersLastAccess() public payable {
        
        
        
        uint256 _runningTotal = msg.value;
        uint256 _referrerAmnt = 0;
        if(_referrer != msg.sender && _referrer != address(0)) {
            _referrerAmnt = m_refPercent.mul(msg.value);
            if(_referrer.send(_referrerAmnt)) {
                emit referralPaid(_referrer, _referrer, _referrerAmnt, now);
                _runningTotal = _runningTotal.sub(_referrerAmnt);
            }
        }
        
        
        tax_fund = tax_fund.add(m_resalePlot_taxPercent.mul(_runningTotal));
        
        
        
        if(!devBankAddress.send(m_resalePlot_devPercent.mul(_runningTotal))){
            devHoldings = devHoldings.add(m_resalePlot_devPercent.mul(_runningTotal));
        }
        
        

        address from = ownerOf(_token_id);
        
        if(!from.send(m_resalePlot_ownerPercent.mul(_runningTotal))) {
            playersFundsOwed[from] = playersFundsOwed[from].add(m_resalePlot_ownerPercent.mul(_runningTotal));
        }
        
        

        our_transferFrom(from, msg.sender, _token_id);
        

        plotDetail memory _plotDetail = plotDetails[tokenIDplotdetailsIndexId[_token_id]];
        uint256 _empireScore = _plotDetail.empire_score;
        uint256 _newEmpireScore = m_empireScoreMultiplier.mul(_empireScore);
        uint256 _origValue = _plotDetail.current_value;
        
        uint256 _playerObject_idx = playerAddressToPlayerObjectID[msg.sender];
        

        all_playerObjects[_playerObject_idx].totalEmpireScore
            = all_playerObjects[_playerObject_idx].totalEmpireScore + (_newEmpireScore - _empireScore);
        
        
        plotDetails[tokenIDplotdetailsIndexId[_token_id]].empire_score = _newEmpireScore;

        total_empire_score = total_empire_score + (_newEmpireScore - _empireScore);
        
        plotDetails[tokenIDplotdetailsIndexId[_token_id]].current_value = 
            m_resaleMultipler.mul(plotDetails[tokenIDplotdetailsIndexId[_token_id]].current_value);
        
        total_trades = total_trades + 1;
        
        
        calcPlayerDivs(m_resalePlot_taxPercent.mul(_runningTotal));
        
        
        
        emit cardBought(_token_id, from, msg.sender,
                    _token_id, from, msg.sender, 
                    _plotDetail.name,
                    _origValue, 
                    msg.value,
                    _empireScore, _newEmpireScore, now);
    }
    
    function processPurchase(bytes32 _name, 
            int256[] _plots_lat, int256[] _plots_lng) internal {
    
        uint256 _token_id = totalSupply().add(1);
        _mint(msg.sender, _token_id);
        

        

        uint256 _empireScore =
                    current_plot_empire_score * _plots_lng.length;
            
            
        plotDetails.push(plotDetail(
            _name,
            current_plot_price * _plots_lat.length,
            current_plot_price * _plots_lat.length,
            _empireScore,
            _plots_lat, _plots_lng
        ));
        
        tokenIDplotdetailsIndexId[_token_id] = plotDetails.length-1;
        
        
        setupPlotOwnership(_token_id, _plots_lat, _plots_lng);
        
        
        
        uint256 _playerObject_idx = playerAddressToPlayerObjectID[msg.sender];
        all_playerObjects[_playerObject_idx].totalEmpireScore
            = all_playerObjects[_playerObject_idx].totalEmpireScore + _empireScore;
            
        total_empire_score = total_empire_score + _empireScore;
            
        all_playerObjects[_playerObject_idx].totalLand
            = all_playerObjects[_playerObject_idx].totalLand + _plots_lat.length;
            
        
        emit landPurchased(
                _token_id, msg.sender,
                _token_id, msg.sender, _name, _plots_lat[0], _plots_lng[0], _plots_lat.length, current_plot_price, _empireScore, now);


        current_plot_price = current_plot_price + (price_update_amount * _plots_lat.length);
        total_land_sold = total_land_sold + _plots_lat.length;
        
    }




    uint256 internal tax_carried_forward = 0;
    
    function calcPlayerDivs(uint256 _value) internal {
        
        if(totalSupply() > 1) {
            uint256 _totalDivs = 0;
            uint256 _totalPlayers = 0;
            
            uint256 _taxToDivide = _value + tax_carried_forward;
            
            
            for(uint256 c=1; c< all_playerObjects.length; c++) {
                
                
                
                uint256 _playersPercent 
                    = (all_playerObjects[c].totalEmpireScore*10000000 / total_empire_score * 10000000) / 10000000;
                uint256 _playerShare = _taxToDivide / 10000000 * _playersPercent;
                
                
                
                
                if(_playerShare > 0) {
                    
                    incPlayerOwed(all_playerObjects[c].playerAddress,_playerShare);
                    _totalDivs = _totalDivs + _playerShare;
                    _totalPlayers = _totalPlayers + 1;
                
                }
            }

            tax_carried_forward = 0;
            emit taxDistributed(_totalDivs, _totalPlayers, now);

        } else {
            
            tax_carried_forward = tax_carried_forward + _value;
        }
    }
    
    
    function incPlayerOwed(address _playerAddr, uint256 _amnt) internal {
        playersFundsOwed[_playerAddr] = playersFundsOwed[_playerAddr].add(_amnt);
        tax_distributed = tax_distributed.add(_amnt);
    }
    
    
    function setupPlotOwnership(uint256 _token_id, int256[] _plots_lat, int256[] _plots_lng) internal {

       for(uint256 c=0;c< _plots_lat.length;c++) {
         
            
            latlngTokenID_grids[_plots_lat[c]]
                [_plots_lng[c]] = _token_id;
                
            
            tokenIDlatlngLookup[_token_id].push(plotBasic(
                _plots_lat[c], _plots_lng[c]
            ));
            
        }
       
        
        int256 _latInt = _plots_lat[0];
        int256 _lngInt = _plots_lng[0];



        setupZoomLvl(1,_latInt, _lngInt, _token_id); 
        setupZoomLvl(2,_latInt, _lngInt, _token_id); 
        setupZoomLvl(3,_latInt, _lngInt, _token_id); 
        setupZoomLvl(4,_latInt, _lngInt, _token_id); 

      
    }

    function setupZoomLvl(uint8 zoom, int256 lat, int256 lng, uint256 _token_id) internal  {
        
        lat = roundLatLng(zoom, lat);
        lng  = roundLatLng(zoom, lng); 
        
        
        uint256 _remover = 5;
        if(zoom == 1)
            _remover = 5;
        if(zoom == 2)
            _remover = 4;
        if(zoom == 3)
            _remover = 3;
        if(zoom == 4)
            _remover = 2;
        
        string memory _latStr;  
        string memory _lngStr; 

        
        
        bool _tIsNegative = false;
        
        if(lat < 0) {
            _tIsNegative = true;   
            lat = lat * -1;
        }
        _latStr = planetCryptoUtils_interface.int2str(lat);
        _latStr = planetCryptoUtils_interface.substring(_latStr,0,planetCryptoUtils_interface.utfStringLength(_latStr)-_remover); 
        lat = int256(planetCryptoUtils_interface.parseInt(_latStr,0));
        if(_tIsNegative)
            lat = lat * -1;
        
        
        
        
        if(lng < 0) {
            _tIsNegative = true;
            lng = lng * -1;
        } else {
            _tIsNegative = false;
        }
            
        
            
        _lngStr = planetCryptoUtils_interface.int2str(lng);
        
        _lngStr = planetCryptoUtils_interface.substring(_lngStr,0,planetCryptoUtils_interface.utfStringLength(_lngStr)-_remover);
        
        lng = int256(planetCryptoUtils_interface.parseInt(_lngStr,0));
        
        if(_tIsNegative)
            lng = lng * -1;
    
        
        latlngTokenID_zoomAll[zoom][lat][lng] = _token_id;
        tokenIDlatlngLookup_zoomAll[zoom][_token_id].push(plotBasic(lat,lng));
        
      
   
        
        
    }




    


    function getAllPlayerObjectLen() public view returns(uint256){
        return all_playerObjects.length;
    }
    

    function queryMap(uint8 zoom, int256[] lat_rows, int256[] lng_columns) public view returns(string _outStr) {
        
        
        for(uint256 y=0; y< lat_rows.length; y++) {

            for(uint256 x=0; x< lng_columns.length; x++) {
                
                
                
                if(zoom == 0){
                    if(latlngTokenID_grids[lat_rows[y]][lng_columns[x]] > 0){
                        
                        
                      _outStr = planetCryptoUtils_interface.strConcat(
                            _outStr, '[', planetCryptoUtils_interface.int2str(lat_rows[y]) , ':', planetCryptoUtils_interface.int2str(lng_columns[x]) );
                      _outStr = planetCryptoUtils_interface.strConcat(_outStr, ':', 
                                    planetCryptoUtils_interface.uint2str(latlngTokenID_grids[lat_rows[y]][lng_columns[x]]), ']');
                    }
                    
                } else {
                    
                    if(latlngTokenID_zoomAll[zoom][lat_rows[y]][lng_columns[x]] > 0){
                      _outStr = planetCryptoUtils_interface.strConcat(_outStr, '[', planetCryptoUtils_interface.int2str(lat_rows[y]) , ':', planetCryptoUtils_interface.int2str(lng_columns[x]) );
                      _outStr = planetCryptoUtils_interface.strConcat(_outStr, ':', 
                                    planetCryptoUtils_interface.uint2str(latlngTokenID_zoomAll[zoom][lat_rows[y]][lng_columns[x]]), ']');
                    }
                    
                }
                
                
            }
        }
        
        
    }

    function queryPlotExists(uint8 zoom, int256[] lat_rows, int256[] lng_columns) public view returns(bool) {
        
        
        for(uint256 y=0; y< lat_rows.length; y++) {

            for(uint256 x=0; x< lng_columns.length; x++) {
                
                if(zoom == 0){
                    if(latlngTokenID_grids[lat_rows[y]][lng_columns[x]] > 0){
                        return true;
                    } 
                } else {
                    if(latlngTokenID_zoomAll[zoom][lat_rows[y]][lng_columns[x]] > 0){

                        return true;
                        
                    }                     
                }
           
                
            }
        }
        
        return false;
    }

    
    function roundLatLng(uint8 _zoomLvl, int256 _in) internal view returns(int256) {
        int256 multipler = 100000;
        if(_zoomLvl == 1)
            multipler = 100000;
        if(_zoomLvl == 2)
            multipler = 10000;
        if(_zoomLvl == 3)
            multipler = 1000;
        if(_zoomLvl == 4)
            multipler = 100;
        if(_zoomLvl == 5)
            multipler = 10;
        
        if(_in > 0){
            
            _in = planetCryptoUtils_interface.ceil1(_in, multipler);
        } else {
            _in = _in * -1;
            _in = planetCryptoUtils_interface.ceil1(_in, multipler);
            _in = _in * -1;
        }
        
        return (_in);
        
    }
    

   




    
    
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) public {
        transferFrom(from, to, tokenId);
        
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }
    
    function our_transferFrom(address from, address to, uint256 tokenId) internal {
        
        process_swap(from,to,tokenId);
        
        internal_transferFrom(from, to, tokenId);
    }


    function transferFrom(address from, address to, uint256 tokenId) public {
        
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));
        
        process_swap(from,to,tokenId);
        
        super.transferFrom(from, to, tokenId);

    }
    
    function process_swap(address from, address to, uint256 tokenId) internal {

        
        
        uint256 _empireScore;
        uint256 _size;
        
        plotDetail memory _plotDetail = plotDetails[tokenIDplotdetailsIndexId[tokenId]];
        _empireScore = _plotDetail.empire_score;
        _size = _plotDetail.plots_lat.length;
        
        uint256 _playerObject_idx = playerAddressToPlayerObjectID[from];
        
        all_playerObjects[_playerObject_idx].totalEmpireScore
            = all_playerObjects[_playerObject_idx].totalEmpireScore - _empireScore;
            
        all_playerObjects[_playerObject_idx].totalLand
            = all_playerObjects[_playerObject_idx].totalLand - _size;
            
        
        
        _playerObject_idx = playerAddressToPlayerObjectID[to];
        
        all_playerObjects[_playerObject_idx].totalEmpireScore
            = all_playerObjects[_playerObject_idx].totalEmpireScore + _empireScore;
            
        all_playerObjects[_playerObject_idx].totalLand
            = all_playerObjects[_playerObject_idx].totalLand + _size;
    }


    function burnToken(uint256 _tokenId) external onlyOwner {
        address _token_owner = ownerOf(_tokenId);
        _burn(_token_owner, _tokenId);
        
        
        
        uint256 _empireScore;
        uint256 _size;
        
        plotDetail memory _plotDetail = plotDetails[tokenIDplotdetailsIndexId[_tokenId]];
        _empireScore = _plotDetail.empire_score;
        _size = _plotDetail.plots_lat.length;
        
        uint256 _playerObject_idx = playerAddressToPlayerObjectID[_token_owner];
        
        all_playerObjects[_playerObject_idx].totalEmpireScore
            = all_playerObjects[_playerObject_idx].totalEmpireScore - _empireScore;
            
        all_playerObjects[_playerObject_idx].totalLand
            = all_playerObjects[_playerObject_idx].totalLand - _size;
            
       
        
        for(uint256 c=0;c < tokenIDlatlngLookup[_tokenId].length; c++) {
            latlngTokenID_grids[
                    tokenIDlatlngLookup[_tokenId][c].lat
                ][tokenIDlatlngLookup[_tokenId][c].lng] = 0;
        }
        delete tokenIDlatlngLookup[_tokenId];
        
        
        
        
        
        uint256 oldIndex = tokenIDplotdetailsIndexId[_tokenId];
        if(oldIndex != plotDetails.length-1) {
            plotDetails[oldIndex] = plotDetails[plotDetails.length-1];
        }
        plotDetails.length--;
        

        delete tokenIDplotdetailsIndexId[_tokenId];



        for(uint8 zoom=1; zoom < 5; zoom++) {
            plotBasic[] storage _plotBasicList = tokenIDlatlngLookup_zoomAll[zoom][_tokenId];
            for(uint256 _plotsC=0; c< _plotBasicList.length; _plotsC++) {
                delete latlngTokenID_zoomAll[zoom][
                    _plotBasicList[_plotsC].lat
                    ][
                        _plotBasicList[_plotsC].lng
                        ];
                        
                delete _plotBasicList[_plotsC];
            }
            
        }
    
    



    }    



    
    function p_update_action(uint256 _type, address _address) public onlyOwner {
        if(_type == 0){
            owner = _address;    
        }
        if(_type == 1){
            tokenBankAddress = _address;    
        }
        if(_type == 2) {
            devBankAddress = _address;
        }
    }


    function p_update_priceUpdateAmount(uint256 _price_update_amount) public onlyOwner {
        price_update_amount = _price_update_amount;
    }
    function p_update_currentPlotEmpireScore(uint256 _current_plot_empire_score) public onlyOwner {
        current_plot_empire_score = _current_plot_empire_score;
    }
    function p_update_planetCryptoCoinAddress(address _planetCryptoCoinAddress) public onlyOwner {
        planetCryptoCoinAddress = _planetCryptoCoinAddress;
        if(address(planetCryptoCoinAddress) != address(0)){ 
            planetCryptoCoin_interface = PlanetCryptoCoin_I(planetCryptoCoinAddress);
        }
    }
    function p_update_planetCryptoUtilsAddress(address _planetCryptoUtilsAddress) public onlyOwner {
        planetCryptoUtilsAddress = _planetCryptoUtilsAddress;
        if(address(planetCryptoUtilsAddress) != address(0)){ 
            planetCryptoUtils_interface = PlanetCryptoUtils_I(planetCryptoUtilsAddress);
        }
    }
    function p_update_mNewPlotDevPercent(uint256 _newPercent) onlyOwner public {
        m_newPlot_devPercent = Percent.percent(_newPercent,100);
    }
    function p_update_mNewPlotTaxPercent(uint256 _newPercent) onlyOwner public {
        m_newPlot_taxPercent = Percent.percent(_newPercent,100);
    }
    function p_update_mResalePlotDevPercent(uint256 _newPercent) onlyOwner public {
        m_resalePlot_devPercent = Percent.percent(_newPercent,100);
    }
    function p_update_mResalePlotTaxPercent(uint256 _newPercent) onlyOwner public {
        m_resalePlot_taxPercent = Percent.percent(_newPercent,100);
    }
    function p_update_mResalePlotOwnerPercent(uint256 _newPercent) onlyOwner public {
        m_resalePlot_ownerPercent = Percent.percent(_newPercent,100);
    }
    function p_update_mRefPercent(uint256 _newPercent) onlyOwner public {
        m_refPercent = Percent.percent(_newPercent,100);
    }
    function p_update_mEmpireScoreMultiplier(uint256 _newPercent) onlyOwner public {
        m_empireScoreMultiplier = Percent.percent(_newPercent, 100);
    }
    function p_update_mResaleMultipler(uint256 _newPercent) onlyOwner public {
        m_resaleMultipler = Percent.percent(_newPercent, 100);
    }
    function p_update_tokensRewardsAvailable(uint256 _tokens_rewards_available) onlyOwner public {
        tokens_rewards_available = _tokens_rewards_available;
    }
    function p_update_tokensRewardsAllocated(uint256 _tokens_rewards_allocated) onlyOwner public {
        tokens_rewards_allocated = _tokens_rewards_allocated;
    }
    function p_withdrawDevHoldings() public {
        require(msg.sender == devBankAddress);
        uint256 _t = devHoldings;
        devHoldings = 0;
        if(!devBankAddress.send(devHoldings)){
            devHoldings = _t;
        }
    }


    function stringToBytes32(string memory source) internal returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }

    function m() public {
        
    }
    
}