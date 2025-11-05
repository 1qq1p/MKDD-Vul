pragma solidity ^0.4.25;








contract Art_MuYiChen_No1 is StandardToken {
    function () {
        
        throw;
    }

    

    





    string public name;
    uint8 public decimals;
    string public symbol;

    function Art_MuYiChen_No1(
        ) {
        name = "Art.MuYiChen.No1";
        symbol = "MYChen.1";
        decimals = 8;
        totalSupply = 7140;
        balances[msg.sender] = 714000000000;
    }
    
    function getIssuer() public view returns(string) { return "LIN, FANG-PAN"; }
    function getImage() public view returns(string) { return "https://swarm-gateways.net/bzz:/9acc21ea16d0ec4b3424439ba7d8b133f11a9a93be858be43636d7fc9ea8f7bf/"; }
    function getArtist() public view returns(string) { return "MuYiChen"; }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}