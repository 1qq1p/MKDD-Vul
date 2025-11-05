pragma solidity ^0.4.23;






contract NamiTrade{
    using SafeMath for uint256;
    
    uint public minNac = 0; 
    uint public minWithdraw =  100 * 10**18;
    uint public maxWithdraw = 100000 * 10**18; 
    
    constructor(address _escrow, address _namiMultiSigWallet, address _namiAddress) public {
        require(_namiMultiSigWallet != 0x0);
        escrow = _escrow;
        namiMultiSigWallet = _namiMultiSigWallet;
        NamiAddr = _namiAddress; 
    }
    
    
    
    uint public NetfBalance;
    





    
    
    
    address public escrow;

    
    address public namiMultiSigWallet;
    
    
    address public NamiAddr;
    
    modifier onlyEscrow() {
        require(msg.sender == escrow);
        _;
    }
    
    modifier onlyNami {
        require(msg.sender == NamiAddr);
        _;
    }
    
    modifier onlyNamiMultisig {
        require(msg.sender == namiMultiSigWallet);
        _;
    }
    
    modifier onlyController {
        require(isController[msg.sender] == true);
        _;
    }
    
    
    



    mapping(address => bool) public isController;
    
    
    
    
    




    function setController(address _controller)
        public
        onlyEscrow
    {
        require(!isController[_controller]);
        isController[_controller] = true;
    }
    
    




    function removeController(address _controller)
        public
        onlyEscrow
    {
        require(isController[_controller]);
        isController[_controller] = false;
    }
    
    
    
    function changeMinNac(uint _minNAC) public
        onlyEscrow
    {
        require(_minNAC != 0);
        minNac = _minNAC;
    }
    
    
    function changeEscrow(address _escrow) public
        onlyNamiMultisig
    {
        require(_escrow != 0x0);
        escrow = _escrow;
    }
    
    
    
    function changeMinWithdraw(uint _minWithdraw) public
        onlyEscrow
    {
        require(_minWithdraw != 0);
        minWithdraw = _minWithdraw;
    }
    
    function changeMaxWithdraw(uint _maxNac) public
        onlyEscrow
    {
        require(_maxNac != 0);
        maxWithdraw = _maxNac;
    }
    
    
    
    function withdrawEther(uint _amount) public
        onlyEscrow
    {
        require(namiMultiSigWallet != 0x0);
        
        if (address(this).balance > 0) {
            namiMultiSigWallet.transfer(_amount);
        }
    }
    
    
    
    
    function withdrawNac(uint _amount) public
        onlyEscrow
    {
        require(namiMultiSigWallet != 0x0);
        
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        if (namiToken.balanceOf(address(this)) > 0) {
            namiToken.transfer(namiMultiSigWallet, _amount);
        }
    }
    
    




    event Deposit(address indexed user, uint amount, uint timeDeposit);
    event Withdraw(address indexed user, uint amount, uint timeWithdraw);
    
    event PlaceBuyFciOrder(address indexed investor, uint amount, uint timePlaceOrder);
    event PlaceSellFciOrder(address indexed investor, uint amount, uint timePlaceOrder);
    event InvestToNLF(address indexed investor, uint amount, uint timeInvest);
    
    
    
    
    string public name = "Nami Trade";
    string public symbol = "FCI";
    uint8 public decimals = 18;
    
    uint256 public totalSupply;
    
    
    bool public isPause;
    
    
    uint256 public timeExpires;
    
    
    uint public fciDecimals = 1000000;
    uint256 public priceFci;
    
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Burn(address indexed from, uint256 value);
    
    
    event BuyFci(address investor, uint256 valueNac, uint256 valueFci, uint timeBuyFci);
    event SellFci(address investor, uint256 valueNac, uint256 valueFci, uint timeSellFci);
    
    modifier onlyRunning {
        require(isPause == false);
        _;
    }
    
    
    


    function addNacToNetf(uint _valueNac) public onlyController {
        NetfBalance = NetfBalance.add(_valueNac);
    }
    
    
    


    function removeNacFromNetf(uint _valueNac) public onlyController {
        NetfBalance = NetfBalance.sub(_valueNac);
    }
    
    
    


    function changePause() public onlyController {
        isPause = !isPause;
    }
    
    




     function updatePriceFci(uint _price, uint _timeExpires) onlyController public {
         require(now > timeExpires);
         priceFci = _price;
         timeExpires = _timeExpires;
     }
    
    




    function buyFci(address _buyer, uint _valueNac) onlyController public {
        
        require(isPause == false && now < timeExpires);
        
        require(_buyer != 0x0);
        require( _valueNac * fciDecimals > priceFci);
        uint fciReceive = (_valueNac.mul(fciDecimals))/priceFci;
        
        
        balanceOf[_buyer] = balanceOf[_buyer].add(fciReceive);
        totalSupply = totalSupply.add(fciReceive);
        NetfBalance = NetfBalance.add(_valueNac);
        
        emit Transfer(address(this), _buyer, fciReceive);
        emit BuyFci(_buyer, _valueNac, fciReceive, now);
    }
    
    
    




    function placeSellFciOrder(uint _valueFci) onlyRunning public {
        require(balanceOf[msg.sender] >= _valueFci && _valueFci > 0);
        _transfer(msg.sender, address(this), _valueFci);
        emit PlaceSellFciOrder(msg.sender, _valueFci, now);
    }
    
    




    function sellFci(address _seller, uint _valueFci) onlyController public {
        
        require(isPause == false && now < timeExpires);
        
        require(_seller != 0x0);
        require(_valueFci * priceFci > fciDecimals);
        uint nacReturn = (_valueFci.mul(priceFci))/fciDecimals;
        
        
        balanceOf[address(this)] = balanceOf[address(this)].sub(_valueFci);
        totalSupply = totalSupply.sub(_valueFci);
        
        
        NetfBalance = NetfBalance.sub(nacReturn);
        
        
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        namiToken.transfer(_seller, nacReturn);
        
        emit Transfer(_seller, address(this), _valueFci);
        emit SellFci(_seller, nacReturn, _valueFci, now);
    }
    
    
    struct ShareHolderNETF {
        uint stake;
        bool isWithdrawn;
    }
    
    struct RoundNetfRevenue {
        bool isOpen;
        uint currentNAC;
        uint totalFci;
        bool withdrawable;
    }
    
    uint public currentNetfRound;
    
    mapping (uint => RoundNetfRevenue) public NetfRevenue;
    mapping (uint => mapping(address => ShareHolderNETF)) public usersNETF;
    
    
    


    function openNetfRevenueRound(uint _roundIndex) onlyController public {
        require(NetfRevenue[_roundIndex].isOpen == false);
        currentNetfRound = _roundIndex;
        NetfRevenue[_roundIndex].isOpen = true;
    }
    
    




    function depositNetfRevenue(uint _valueNac) onlyController public {
        require(NetfRevenue[currentNetfRound].isOpen == true && NetfRevenue[currentNetfRound].withdrawable == false);
        NetfRevenue[currentNetfRound].currentNAC = NetfRevenue[currentNetfRound].currentNAC.add(_valueNac);
    }
    
    




    function withdrawNetfRevenue(uint _valueNac) onlyController public {
        require(NetfRevenue[currentNetfRound].isOpen == true && NetfRevenue[currentNetfRound].withdrawable == false);
        NetfRevenue[currentNetfRound].currentNAC = NetfRevenue[currentNetfRound].currentNAC.sub(_valueNac);
    }
    
    
    
    



     function latchTotalFci(uint _roundIndex) onlyController public {
         require(isPause == true && NetfRevenue[_roundIndex].isOpen == true);
         require(NetfRevenue[_roundIndex].withdrawable == false);
         NetfRevenue[_roundIndex].totalFci = totalSupply;
     }
     
     function latchFciUserController(uint _roundIndex, address _investor) onlyController public {
         require(isPause == true && NetfRevenue[_roundIndex].isOpen == true);
         require(NetfRevenue[_roundIndex].withdrawable == false);
         require(balanceOf[_investor] > 0);
         usersNETF[_roundIndex][_investor].stake = balanceOf[_investor];
     }
     
     


     function latchFciUser(uint _roundIndex) public {
         require(isPause == true && NetfRevenue[_roundIndex].isOpen == true);
         require(NetfRevenue[_roundIndex].withdrawable == false);
         require(balanceOf[msg.sender] > 0);
         usersNETF[_roundIndex][msg.sender].stake = balanceOf[msg.sender];
     }
     
     




     function changeWithdrawableNetfRe(uint _roundIndex) onlyController public {
         require(isPause == true && NetfRevenue[_roundIndex].isOpen == true);
         NetfRevenue[_roundIndex].withdrawable = true;
         isPause = false;
     }
     
     
     



     function withdrawNacNetfReController(uint _roundIndex, address _investor) onlyController public {
         require(NetfRevenue[_roundIndex].withdrawable == true && isPause == false && _investor != 0x0);
         require(usersNETF[_roundIndex][_investor].stake > 0 && usersNETF[_roundIndex][_investor].isWithdrawn == false);
         require(NetfRevenue[_roundIndex].totalFci > 0);
         
         uint nacReturn = ( NetfRevenue[_roundIndex].currentNAC.mul(usersNETF[_roundIndex][_investor].stake) ) / NetfRevenue[_roundIndex].totalFci;
         NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
         namiToken.transfer(_investor, nacReturn);
         
         usersNETF[_roundIndex][_investor].isWithdrawn = true;
     }
     
     



     function withdrawNacNetfRe(uint _roundIndex) public {
         require(NetfRevenue[_roundIndex].withdrawable == true && isPause == false);
         require(usersNETF[_roundIndex][msg.sender].stake > 0 && usersNETF[_roundIndex][msg.sender].isWithdrawn == false);
         require(NetfRevenue[_roundIndex].totalFci > 0);
         
         uint nacReturn = ( NetfRevenue[_roundIndex].currentNAC.mul(usersNETF[_roundIndex][msg.sender].stake) ) / NetfRevenue[_roundIndex].totalFci;
         NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
         namiToken.transfer(msg.sender, nacReturn);
         
         usersNETF[_roundIndex][msg.sender].isWithdrawn = true;
     }
    
    
    


    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
        
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        balanceOf[_from] -= _value;
        
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    







    function transfer(address _to, uint256 _value) public onlyRunning {
        _transfer(msg.sender, _to, _value);
    }

    








    function transferFrom(address _from, address _to, uint256 _value) public onlyRunning returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    







    function approve(address _spender, uint256 _value) public onlyRunning
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    








    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public onlyRunning
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    
    
    
    
    
    
    
    
    
    
    uint public currentRound = 1;
    uint public currentSubRound = 1;
    
    struct shareHolderNLF {
        uint fciNLF;
        bool isWithdrawnRound;
    }
    
    struct SubRound {
        uint totalNacInSubRound;
        bool isOpen;
        bool isCloseNacPool;
    }
    
    struct Round {
        bool isOpen;
        bool isActivePool;
        bool withdrawable;
        uint currentNAC;
        uint finalNAC;
    }
    
    
    mapping(uint => Round) public NLFunds;
    mapping(uint => mapping(address => mapping(uint => bool))) public isWithdrawnSubRoundNLF;
    mapping(uint => mapping(uint => SubRound)) public listSubRoundNLF;
    mapping(uint => mapping(address => shareHolderNLF)) public membersNLF;
    
    
    event ActivateRound(uint RoundIndex, uint TimeActive);
    event ActivateSubRound(uint RoundIndex, uint TimeActive);
    
    



    function activateRound(uint _roundIndex)
        onlyEscrow
        public
    {
        
        require(NLFunds[_roundIndex].isOpen == false);
        NLFunds[_roundIndex].isOpen = true;
        currentRound = _roundIndex;
        emit ActivateRound(_roundIndex, now);
    }
    
    
    


    function deactivateRound(uint _roundIndex)
        onlyEscrow
        public
    {
        
        require(NLFunds[_roundIndex].isOpen == true);
        NLFunds[_roundIndex].isActivePool = true;
        NLFunds[_roundIndex].isOpen = false;
        NLFunds[_roundIndex].finalNAC = NLFunds[_roundIndex].currentNAC;
    }
    
    


    function activateSubRound(uint _subRoundIndex)
        onlyController
        public
    {
        
        require(NLFunds[currentRound].isOpen == false && NLFunds[currentRound].isActivePool == true);
        
        require(listSubRoundNLF[currentRound][_subRoundIndex].isOpen == false);
        
        currentSubRound = _subRoundIndex;
        require(listSubRoundNLF[currentRound][_subRoundIndex].isCloseNacPool == false);
        
        listSubRoundNLF[currentRound][_subRoundIndex].isOpen = true;
        emit ActivateSubRound(_subRoundIndex, now);
    }
    
    
    


    function depositToSubRound(uint _value)
        onlyController
        public
    {
        
        require(currentSubRound != 0);
        require(listSubRoundNLF[currentRound][currentSubRound].isOpen == true);
        require(listSubRoundNLF[currentRound][currentSubRound].isCloseNacPool == false);
        
        
        listSubRoundNLF[currentRound][currentSubRound].totalNacInSubRound = listSubRoundNLF[currentRound][currentSubRound].totalNacInSubRound.add(_value);
    }
    
    
    


    function withdrawFromSubRound(uint _value)
        onlyController
        public
    {
        
        require(currentSubRound != 0);
        require(listSubRoundNLF[currentRound][currentSubRound].isOpen == true);
        require(listSubRoundNLF[currentRound][currentSubRound].isCloseNacPool == false);
        
        
        listSubRoundNLF[currentRound][currentSubRound].totalNacInSubRound = listSubRoundNLF[currentRound][currentSubRound].totalNacInSubRound.sub(_value);
    }
    
    
    


    function closeDepositSubRound()
        onlyController
        public
    {
        require(listSubRoundNLF[currentRound][currentSubRound].isOpen == true);
        require(listSubRoundNLF[currentRound][currentSubRound].isCloseNacPool == false);
        
        listSubRoundNLF[currentRound][currentSubRound].isCloseNacPool = true;
    }
    
    
    


    function withdrawSubRound(uint _subRoundIndex) public {
        
        require(listSubRoundNLF[currentRound][_subRoundIndex].isCloseNacPool == true);
        
        
        require(isWithdrawnSubRoundNLF[currentRound][msg.sender][_subRoundIndex] == false);
        
        
        require(membersNLF[currentRound][msg.sender].fciNLF > 0);
        
        
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        
        uint nacReturn = (listSubRoundNLF[currentRound][_subRoundIndex].totalNacInSubRound.mul(membersNLF[currentRound][msg.sender].fciNLF)).div(NLFunds[currentRound].finalNAC);
        namiToken.transfer(msg.sender, nacReturn);
        
        isWithdrawnSubRoundNLF[currentRound][msg.sender][_subRoundIndex] = true;
    }
    
    
    



    function addNacToNLF(uint _value) public onlyController {
        require(NLFunds[currentRound].isActivePool == true);
        require(NLFunds[currentRound].withdrawable == false);
        
        NLFunds[currentRound].currentNAC = NLFunds[currentRound].currentNAC.add(_value);
    }
    
    


    
    function removeNacFromNLF(uint _value) public onlyController {
        require(NLFunds[currentRound].isActivePool == true);
        require(NLFunds[currentRound].withdrawable == false);
        
        NLFunds[currentRound].currentNAC = NLFunds[currentRound].currentNAC.sub(_value);
    }
    
    


    function changeWithdrawableRound(uint _roundIndex)
        public
        onlyEscrow
    {
        require(NLFunds[currentRound].isActivePool == true);
        require(NLFunds[_roundIndex].withdrawable == false && NLFunds[_roundIndex].isOpen == false);
        
        NLFunds[_roundIndex].withdrawable = true;
    }
    
    
    



    function withdrawRound(uint _roundIndex) public {
        require(NLFunds[_roundIndex].withdrawable == true);
        require(membersNLF[currentRound][msg.sender].isWithdrawnRound == false);
        require(membersNLF[currentRound][msg.sender].fciNLF > 0);
        
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        uint nacReturn = NLFunds[currentRound].currentNAC.mul(membersNLF[currentRound][msg.sender].fciNLF).div(NLFunds[currentRound].finalNAC);
        namiToken.transfer(msg.sender, nacReturn);
        
        
        membersNLF[currentRound][msg.sender].isWithdrawnRound = true;
        membersNLF[currentRound][msg.sender].fciNLF = 0;
    }
    
    function withdrawRoundController(uint _roundIndex, address _investor) public onlyController {
        require(NLFunds[_roundIndex].withdrawable == true);
        require(membersNLF[currentRound][_investor].isWithdrawnRound == false);
        require(membersNLF[currentRound][_investor].fciNLF > 0);
        
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        uint nacReturn = NLFunds[currentRound].currentNAC.mul(membersNLF[currentRound][_investor].fciNLF).div(NLFunds[currentRound].finalNAC);
        namiToken.transfer(msg.sender, nacReturn);
        
        
        membersNLF[currentRound][_investor].isWithdrawnRound = true;
        membersNLF[currentRound][_investor].fciNLF = 0;
    }
    
    
    
    



    function tokenFallbackExchange(address _from, uint _value, uint _choose) onlyNami public returns (bool success) {
        require(_choose <= 2);
        if (_choose == 0) {
            
            require(_value >= minNac);
            emit Deposit(_from, _value, now);
        } else if(_choose == 1) {
            require(_value >= minNac && NLFunds[currentRound].isOpen == true);
            
            membersNLF[currentRound][_from].fciNLF = membersNLF[currentRound][_from].fciNLF.add(_value);
            NLFunds[currentRound].currentNAC = NLFunds[currentRound].currentNAC.add(_value);
            
            emit InvestToNLF(_from, _value, now);
        } else if(_choose == 2) {
            
            require(_value >= minNac); 
            emit PlaceBuyFciOrder(_from, _value, now);
        }
        return true;
    }
    
    
    
    
    
    
    
    function withdrawToken(address _account, uint _amount)
        public
        onlyController
    {
        require(_amount >= minWithdraw && _amount <= maxWithdraw);
        NamiCrowdSale namiToken = NamiCrowdSale(NamiAddr);
        
        uint previousBalances = namiToken.balanceOf(address(this));
        require(previousBalances >= _amount);
        
        
        namiToken.transfer(_account, _amount);
        
        
        emit Withdraw(_account, _amount, now);
        assert(previousBalances >= namiToken.balanceOf(address(this)));
    }
    
    
}