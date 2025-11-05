pragma solidity >=0.4.25 <0.6.0;

pragma experimental ABIEncoderV2;














contract SignerManager is Ownable {
    using SafeMathUintLib for uint256;
    
    
    
    
    mapping(address => uint256) public signerIndicesMap; 
    address[] public signers;

    
    
    
    event RegisterSignerEvent(address signer);

    
    
    
    constructor(address deployer) Ownable(deployer) public {
        registerSigner(deployer);
    }

    
    
    
    
    
    
    function isSigner(address _address)
    public
    view
    returns (bool)
    {
        return 0 < signerIndicesMap[_address];
    }

    
    
    function signersCount()
    public
    view
    returns (uint256)
    {
        return signers.length;
    }

    
    
    
    function signerIndex(address _address)
    public
    view
    returns (uint256)
    {
        require(isSigner(_address), "Address not signer [SignerManager.sol:71]");
        return signerIndicesMap[_address] - 1;
    }

    
    
    function registerSigner(address newSigner)
    public
    onlyOperator
    notNullOrThisAddress(newSigner)
    {
        if (0 == signerIndicesMap[newSigner]) {
            
            signers.push(newSigner);
            signerIndicesMap[newSigner] = signers.length;

            
            emit RegisterSignerEvent(newSigner);
        }
    }

    
    
    
    
    function signersByIndices(uint256 low, uint256 up)
    public
    view
    returns (address[] memory)
    {
        require(0 < signers.length, "No signers found [SignerManager.sol:101]");
        require(low <= up, "Bounds parameters mismatch [SignerManager.sol:102]");

        up = up.clampMax(signers.length - 1);
        address[] memory _signers = new address[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _signers[i - low] = signers[i];

        return _signers;
    }
}


















