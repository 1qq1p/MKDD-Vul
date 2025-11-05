pragma solidity 0.4.25;






contract ELD is StandardToken, OnlyOwner{
	uint256 public constant decimals = 18;
    string public constant name = "electrumdark";
    string public constant symbol = "ELD";
    string public constant version = "1.0";
    uint256 public constant totalSupply = 3900000*10**18;
    uint256 private approvalCounts =0;
    uint256 private minRequiredApprovals =2;
    address public burnedTokensReceiver;
    
    constructor() public{
        balances[msg.sender] = totalSupply;
        burnedTokensReceiver = 0x0000000000000000000000000000000000000000;
    }

    



    function setApprovalCounts(uint _value) public isController {
        approvalCounts = _value;
    }
    
    




    function setMinApprovalCounts(uint _value) public isController returns (bool){
        require(_value > 0);
        minRequiredApprovals = _value;
        return true;
    }
    
    



    function getApprovalCount() public view isController returns(uint){
        return approvalCounts;
    }
    
     



    function getBurnedTokensReceiver() public view isController returns(address){
        return burnedTokensReceiver;
    }
    
    
    function controllerApproval(address _from, uint256 _value) public isOwner returns (bool) {
        require(minRequiredApprovals <= approvalCounts);
		require(_value <= balances[_from]);		
        balances[_from] = balances[_from].safeSub(_value);
        balances[burnedTokensReceiver] = balances[burnedTokensReceiver].safeAdd(_value);
        emit Transfer(_from,burnedTokensReceiver, _value);
        return true;
    }
}