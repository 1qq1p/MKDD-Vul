pragma solidity ^0.4.12;

contract UBetCoin is Ownable, StandardToken {

    string public name = "UBetCoin";               
    string public symbol = "UBET";                 
    uint public decimals = 2;                      

    uint256 public totalSupply =  400000000000;      
    uint256 public tokenSupplyFromCheck = 0;             
    uint256 public tokenSupplyBackedByGold = 4000000000; 
    
    string public constant YOU_BET_MINE_DOCUMENT_PATH = "https://s3.amazonaws.com/s3-ubetcoin-user-signatures/document/GOLD-MINES-assigned+TO-SAINT-NICOLAS-SNADCO-03-22-2016.pdf";
    string public constant YOU_BET_MINE_DOCUMENT_SHA512 = "7e9dc6362c5bf85ff19d75df9140b033c4121ba8aaef7e5837b276d657becf0a0d68fcf26b95e76023a33251ac94f35492f2f0af882af4b87b1b1b626b325cf8";
    string public constant UBETCOIN_LEDGER_TO_LEDGER_ENTRY_DOCUMENT_PATH = "https://s3.amazonaws.com/s3-ubetcoin-user-signatures/document/LEDGER-TO-LEDGER+ENTRY-FOR-UBETCOIN+03-20-2018.pdf";
    string public constant UBETCOIN_LEDGER_TO_LEDGER_ENTRY_DOCUMENT_SHA512 = "c8f0ae2602005dd88ef908624cf59f3956107d0890d67d3baf9c885b64544a8140e282366cae6a3af7bfbc96d17f856b55fc4960e2287d4a03d67e646e0e88c6";
    
    
    uint256 public ratePerOneEther = 962;
    uint256 public totalUBetCheckAmounts = 0;

    
    uint64 public issueIndex = 0;

    
    event Issue(uint64 issueIndex, address addr, uint256 tokenAmount);
    
    
    address public moneyWallet = 0xe5688167Cb7aBcE4355F63943aAaC8bb269dc953;

    
    event UbetCheckIssue(string chequeIndex);
      
    struct UBetCheck {
      string accountId;
      string accountNumber;
      string fullName;
      string routingNumber;
      string institution;
      uint256 amount;
      uint256 tokens;
      string checkFilePath;
      string digitalCheckFingerPrint;
    }
    
    mapping (address => UBetCheck) UBetChecks;
    address[] public uBetCheckAccts;
    
    
    
    function UBetCoin() {
        balances[msg.sender] = totalSupply;
    }
  
    

    
    
    function transferOwnership(address _newOwner) onlyOwner {
        balances[_newOwner] = balances[owner];
        balances[owner] = 0;
        Ownable.transferOwnership(_newOwner);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function registerUBetCheck(address _beneficiary, string _accountId,  string _accountNumber, string _routingNumber, string _institution, string _fullname,  uint256 _amount, string _checkFilePath, string _digitalCheckFingerPrint, uint256 _tokens) public payable onlyOwner {
      
      require(_beneficiary != address(0));
      require(bytes(_accountId).length != 0);
      require(bytes(_accountNumber).length != 0);
      require(bytes(_routingNumber).length != 0);
      require(bytes(_institution).length != 0);
      require(bytes(_fullname).length != 0);
      require(_amount > 0);
      require(_tokens > 0);
      require(bytes(_checkFilePath).length != 0);
      require(bytes(_digitalCheckFingerPrint).length != 0);
      
      var __conToken = _tokens * (10**(decimals));
      
      var uBetCheck = UBetChecks[_beneficiary];
      
      uBetCheck.accountId = _accountId;
      uBetCheck.accountNumber = _accountNumber;
      uBetCheck.routingNumber = _routingNumber;
      uBetCheck.institution = _institution;
      uBetCheck.fullName = _fullname;
      uBetCheck.amount = _amount;
      uBetCheck.tokens = _tokens;
      
      uBetCheck.checkFilePath = _checkFilePath;
      uBetCheck.digitalCheckFingerPrint = _digitalCheckFingerPrint;
      
      totalUBetCheckAmounts = safeAdd(totalUBetCheckAmounts, _amount);
      tokenSupplyFromCheck = safeAdd(tokenSupplyFromCheck, _tokens);
      
      uBetCheckAccts.push(_beneficiary) -1;
      
      
      doIssueTokens(_beneficiary, __conToken);
      
      
      UbetCheckIssue(_accountId);
    }
    
    
    function getUBetChecks() public returns (address[]) {
      return uBetCheckAccts;
    }
    
    
    function getUBetCheck(address _address) public returns(string, string, string, string, uint256, string, string) {
            
      return (UBetChecks[_address].accountNumber,
              UBetChecks[_address].routingNumber,
              UBetChecks[_address].institution,
              UBetChecks[_address].fullName,
              UBetChecks[_address].amount,
              UBetChecks[_address].checkFilePath,
              UBetChecks[_address].digitalCheckFingerPrint);
    }
    
    
    
    function () public payable {
      purchaseTokens(msg.sender);
    }

    
    function countUBetChecks() public returns (uint) {
        return uBetCheckAccts.length;
    }
    

    
    
    
    function doIssueTokens(address _beneficiary, uint256 _tokens) internal {
      require(_beneficiary != address(0));    

      
      uint256 increasedTotalSupply = safeAdd(totalSupply, _tokens);
      
      
      totalSupply = increasedTotalSupply;
      
      balances[_beneficiary] = safeAdd(balances[_beneficiary], _tokens);
      
      Transfer(msg.sender, _beneficiary, _tokens);
    
      
      Issue(
          issueIndex++,
          _beneficiary,
          _tokens
      );
    }
    
    
    
    function purchaseTokens(address _beneficiary) public payable {
      
      require(msg.value >= 0.00104 ether);
     
      uint _tokens = safeDiv(safeMul(msg.value, ratePerOneEther), (10**(18-decimals)));
      doIssueTokens(_beneficiary, _tokens);

      
      moneyWallet.transfer(this.balance);
    }
    
    
    
    
    function setMoneyWallet(address _address) public onlyOwner {
        moneyWallet = _address;
    }
    
    
    
    function setRatePerOneEther(uint256 _value) public onlyOwner {
      require(_value >= 1);
      ratePerOneEther = _value;
    }
    
}