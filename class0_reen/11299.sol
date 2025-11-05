




pragma solidity ^0.4.10;

contract DigitalAssetToken is StandardToken() 
{
    string public constant standard = 'DigitalAssetToken 1.0';
    string public symbol;
    string public  name;
    string public  assetID;
    string public  assetMeta;
    string public isVerfied;
    uint8 public constant decimals = 0;
   
    
    function DigitalAssetToken(
    address tokenMaster,
    address requester,
    uint256 initialSupply,
    string assetTokenName,
    string tokenSymbol,
    string _assetID,
    string _assetMeta
    ) {
        
        require(msg.sender == tokenMaster);

        DigitalAssetCoin coinMaster = DigitalAssetCoin(tokenMaster);

        require(coinMaster.vaildBalanceForTokenCreation(requester));
        
        balances[requester] = initialSupply;              
        _totalSupply = initialSupply;                        
        name = assetTokenName;                                   
        symbol = tokenSymbol;                               
        assetID = _assetID;
        assetMeta = _assetMeta;
    } 
}
  