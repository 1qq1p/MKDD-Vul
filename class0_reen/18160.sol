pragma solidity ^0.4.24; contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}

contract Stage1MEI is Staged, Ticker {
    
    bool stagesInitialized;
    
    function Stage1MEI() public {
      ETHFund = address(0x0Da5F4a56c0B57f1D7c918C63022C40c903430aC);
      balances[ETHFund] = totalSupply();
      stages.push(Stage(true, 100, 272, StageState.Closed,0,0));
      stagesInitialized = false;
      ETHUSD = 4750700;
    }
    
    function initStages() external {
        require(stagesInitialized == false);
        stages[0].state = StageState.Open;
        update(0);
        stagesInitialized = true;
    }
    
    function totalSupply() public pure returns (uint256){
        return 100 * (10**7) * 10**18;
    }
    
    function claimTokens() external {
        require(stages[0].state == StageState.Done);
        require(stages[0].contributors[msg.sender].finalized == false);
        uint256 tokens;
        for(uint i = 0; i < stages.length; i++){
            for(uint j = 0; j < stages[i].contributors[msg.sender].funds.length; j++){
                Fund f = stages[i].contributors[msg.sender].funds[j];
                tokens += uint256(calcTokens(i,f.amount,f.raisedAt));
            }
        }
        uint256 claimableTokens = tokens - balances[msg.sender];
        require(_transfer(ETHFund,msg.sender,claimableTokens));
        stages[0].contributors[msg.sender].finalized = true;
    }
    
    function calcTokens(uint256 stage, uint256 amountContributed, uint256 raisedAt) internal returns (int256){
        int256 T = int256(stages[stage].tokensRaised);
        int256 L = int256(stages[stage].lowerBound);
        int256 U = int256(stages[stage].upperBound);
        
    	int256 a=((U-L)/2);
    	int256 b = 0;
    	if(raisedAt > 0){
    	    b=(L*T+(calcTokens(stage,raisedAt,0)*(U-L))-a);
    	}else{
    	    b=(L*T+(0*(U-L))-a);
    	}
    	assert(b != 0);
    	int256 c=-(int256(amountContributed)*10**18)*T;
    	return ((-b+sqrt(b*b-4*a*c))/(2*a))+1;
    }
    
    function funder(address funder) public returns(uint256 raisedAt, uint256 fundamt){
        return (stages[0].contributors[funder].funds[0].raisedAt,stages[0].contributors[funder].funds[0].amount);
    }
    
    function sqrt(int256 x) internal returns (int256 y) {
        if (x == 0) return 0;
        else if (x <= 3) return 1;
        int z = (x + 1) / 2;
        y = x;
        while (z < y)
        {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
    function ExchangeRate(uint256 weiValue) public view returns(uint256 exchanged, uint256 remainder){
        uint256 ExchRate = 1000000000000000000/ETHUSD;
        uint256 returnVal = weiValue / ExchRate;
        weiValue = weiValue % ExchRate;
        return (returnVal,weiValue);
    }
}