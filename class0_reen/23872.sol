pragma solidity ^0.4.24;


contract BaseAdvertisement is StorageUser,Ownable {
    
    AppCoins public appc;
    BaseFinance public advertisementFinance;
    BaseAdvertisementStorage public advertisementStorage;

    mapping( bytes32 => mapping(address => uint256)) public userAttributions;

    bytes32[] public bidIdList;
    bytes32 public lastBidId = 0x0;


    






    constructor(address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public {
        appc = AppCoins(_addrAppc);

        advertisementStorage = BaseAdvertisementStorage(_addrAdverStorage);
        advertisementFinance = BaseFinance(_addrAdverFinance);
        lastBidId = advertisementStorage.getLastBidId();
    }



    







    function importBidIds(address _addrAdvert) public onlyOwner("importBidIds") {

        bytes32[] memory _bidIdsToImport = BaseAdvertisement(_addrAdvert).getBidIdList();
        bytes32 _lastStorageBidId = advertisementStorage.getLastBidId();

        for (uint i = 0; i < _bidIdsToImport.length; i++) {
            bidIdList.push(_bidIdsToImport[i]);
        }
        
        if(lastBidId < _lastStorageBidId) {
            lastBidId = _lastStorageBidId;
        }
    }

    







    function upgradeFinance (address addrAdverFinance) public onlyOwner("upgradeFinance") {
        BaseFinance newAdvFinance = BaseFinance(addrAdverFinance);

        address[] memory devList = advertisementFinance.getUserList();
        
        for(uint i = 0; i < devList.length; i++){
            uint balance = advertisementFinance.getUserBalance(devList[i]);
            newAdvFinance.increaseBalance(devList[i],balance);
        }
        
        uint256 initBalance = appc.balanceOf(address(advertisementFinance));
        advertisementFinance.transferAllFunds(address(newAdvFinance));
        uint256 oldBalance = appc.balanceOf(address(advertisementFinance));
        uint256 newBalance = appc.balanceOf(address(newAdvFinance));
        
        require(initBalance == newBalance);
        require(oldBalance == 0);
        advertisementFinance = newAdvFinance;
    }

    








    function upgradeStorage (address addrAdverStorage) public onlyOwner("upgradeStorage") {
        for(uint i = 0; i < bidIdList.length; i++) {
            cancelCampaign(bidIdList[i]);
        }
        delete bidIdList;

        lastBidId = advertisementStorage.getLastBidId();
        advertisementFinance.setAdsStorageAddress(addrAdverStorage);
        advertisementStorage = BaseAdvertisementStorage(addrAdverStorage);
    }


    









    function getStorageAddress() public view returns(address storageContract) {
        require (msg.sender == address(advertisementFinance));

        return address(advertisementStorage);
    }


    

















    function _generateCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate)
        internal returns (CampaignLibrary.Campaign memory) {

        require(budget >= price);
        require(endDate >= startDate);


        
        if(appc.allowance(msg.sender, address(this)) >= budget){
            appc.transferFrom(msg.sender, address(advertisementFinance), budget);

            advertisementFinance.increaseBalance(msg.sender,budget);

            uint newBidId = bytesToUint(lastBidId);
            lastBidId = uintToBytes(++newBidId);
            

            CampaignLibrary.Campaign memory newCampaign;
            newCampaign.price = price;
            newCampaign.startDate = startDate;
            newCampaign.endDate = endDate;
            newCampaign.budget = budget;
            newCampaign.owner = msg.sender;
            newCampaign.valid = true;
            newCampaign.bidId = lastBidId;
        } else {
            emit Error("createCampaign","Not enough allowance");
        }
        
        return newCampaign;
    }

    function _getStorage() internal returns (BaseAdvertisementStorage) {
        return advertisementStorage;
    }

    function _getFinance() internal returns (BaseFinance) {
        return advertisementFinance;
    }

    function _setUserAttribution(bytes32 _bidId,address _user,uint256 _attributions) internal{
        userAttributions[_bidId][_user] = _attributions;
    }


    function getUserAttribution(bytes32 _bidId,address _user) internal returns (uint256) {
        return userAttributions[_bidId][_user];
    }

    







    function cancelCampaign (bytes32 bidId) public {
        address campaignOwner = getOwnerOfCampaign(bidId);

		
        require(owner == msg.sender || campaignOwner == msg.sender);
        uint budget = getBudgetOfCampaign(bidId);

        advertisementFinance.withdraw(campaignOwner, budget);

        advertisementStorage.setCampaignBudgetById(bidId, 0);
        advertisementStorage.setCampaignValidById(bidId, false);
    }

     




    function getCampaignValidity(bytes32 bidId) public view returns(bool state){
        return advertisementStorage.getCampaignValidById(bidId);
    }

    





    function getPriceOfCampaign (bytes32 bidId) public view returns(uint price) {
        return advertisementStorage.getCampaignPriceById(bidId);
    }

    






    function getStartDateOfCampaign (bytes32 bidId) public view returns(uint startDate) {
        return advertisementStorage.getCampaignStartDateById(bidId);
    }

    






    function getEndDateOfCampaign (bytes32 bidId) public view returns(uint endDate) {
        return advertisementStorage.getCampaignEndDateById(bidId);
    }

    





    function getBudgetOfCampaign (bytes32 bidId) public view returns(uint budget) {
        return advertisementStorage.getCampaignBudgetById(bidId);
    }


    





    function getOwnerOfCampaign (bytes32 bidId) public view returns(address campaignOwner) {
        return advertisementStorage.getCampaignOwnerById(bidId);
    }

    




    function getBidIdList() public view returns(bytes32[] bidIds) {
        return bidIdList;
    }

    function _getBidIdList() internal returns(bytes32[] storage bidIds){
        return bidIdList;
    }

    






    function isCampaignValid(bytes32 bidId) public view returns(bool valid) {
        uint startDate = advertisementStorage.getCampaignStartDateById(bidId);
        uint endDate = advertisementStorage.getCampaignEndDateById(bidId);
        bool validity = advertisementStorage.getCampaignValidById(bidId);

        uint nowInMilliseconds = now * 1000;
        return validity && startDate < nowInMilliseconds && endDate > nowInMilliseconds;
    }

    





    function uintToBytes (uint256 i) public view returns(bytes32 b) {
        b = bytes32(i);
    }

    function bytesToUint(bytes32 b) public view returns (uint) 
    {
        return uint(b) & 0xfff;
    }

}

