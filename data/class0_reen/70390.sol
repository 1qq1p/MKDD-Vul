pragma solidity ^0.4.24;






contract CryptoMotors is Ownable, ERC721Full {
    string public name = "CryptoMotors";
    string public symbol = "CM";
    
    event CryptoMotorCreated(address receiver, uint cryptoMotorId, string uri);
    event CryptoMotorTransferred(address from, address to, uint cryptoMotorId, string uri);
    event CryptoMotorUriChanged(uint cryptoMotorId, string uri);
    event CryptoMotorDnaChanged(uint cryptoMotorId, string dna);
    

    struct CryptoMotor {
        string dna;
        uint32 level;
        uint32 readyTime;
        uint32 winCount;
        uint32 lossCount;
        address designerWallet;
    }

    CryptoMotor[] public cryptoMotors;

    constructor() ERC721Full(name, symbol) public { }

    
    function create(address owner, string _uri, string _dna, address _designerWallet) public onlyOwner returns (uint) {
        uint id = cryptoMotors.push(CryptoMotor(_dna, 1, uint32(now + 1 days), 0, 0, _designerWallet)) - 1;
        _mint(owner, id);
        _setTokenURI(id, _uri);
        emit CryptoMotorCreated(owner, id, _uri);
        return id;
    }

    function setTokenURI(uint256 _cryptoMotorId, string _uri) public onlyOwner {
        _setTokenURI(_cryptoMotorId, _uri);
        emit CryptoMotorUriChanged(_cryptoMotorId, _uri);
    }
    
    function setCryptoMotorDna(uint _cryptoMotorId, string _dna) public onlyOwner {
        CryptoMotor storage cm = cryptoMotors[_cryptoMotorId];
        cm.dna = _dna;
        emit CryptoMotorDnaChanged(_cryptoMotorId, _dna);
    }

    function getDesignerWallet(uint256 _cryptoMotorId) public view returns (address) {
        return cryptoMotors[_cryptoMotorId].designerWallet;
    }

    function setApprovalsForAll(address[] _addresses, bool approved) public {
        for(uint i; i < _addresses.length; i++) {
            setApprovalForAll(_addresses[i], approved);
        }
    }

    function setAttributes(uint256 _cryptoMotorId, uint32 _level, uint32 _readyTime, uint32 _winCount, uint32 _lossCount) public onlyOwner {
        CryptoMotor storage cm = cryptoMotors[_cryptoMotorId];
        cm.level = _level;
        cm.readyTime = _readyTime;
        cm.winCount = _winCount;
        cm.lossCount = _lossCount;
    }

    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}