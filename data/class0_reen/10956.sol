pragma solidity ^0.4.15;









contract MiniMeTokenI is ERC20Token, Controlled {

    string public name;                
    uint8 public decimals;             
    string public symbol;              
    string public version = "MMT_0.1"; 





    
    
    
    
    
    
    
    function approveAndCall(
        address _spender,
        uint256 _amount,
        bytes _extraData
    ) returns (bool success);





    
    
    
    
    function balanceOfAt(
        address _owner,
        uint _blockNumber
    ) constant returns (uint);

    
    
    
    function totalSupplyAt(uint _blockNumber) constant returns(uint);





    
    
    
    
    
    
    
    
    
    
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
    ) returns(address);





    
    
    
    
    function generateTokens(address _owner, uint _amount) returns (bool);


    
    
    
    
    function destroyTokens(address _owner, uint _amount) returns (bool);





    
    
    function enableTransfers(bool _transfersEnabled);





    
    
    
    
    function claimTokens(address _token);





    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
}








