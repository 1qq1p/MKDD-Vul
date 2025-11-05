pragma solidity ^0.4.25;

contract MonaLisa is StandardToken {

    function MonaLisa() public { 
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
    function () {
        
        throw;
    }

    

    





    string public name = "MonaLisa";
    string public symbol = "ML";
    uint public decimals = 8;
    uint public INITIAL_SUPPLY = 735130 * (10 ** decimals);
    string public Image_root = "https://swarm-gateways.net/bzz:/0c429c6423e3fd17490dee0fd7c76cc9469bd7f9eb94411c009e1335f889880a/";
    string public Note_root = "https://swarm-gateways.net/bzz:/835ab8e3f3500f7c0d21bfc8aa27feaf75ae599208fcb08295353a6c9f87e6eb/";
    string public DigestCode_root = "a27b15a6339ba2c40721ee12bd8e49051679c274b1576eeef5c3a5c6837322d3";
    function getIssuer() public view returns(string) { return  "MuseeDuLouvre"; }
    function getArtist() public view returns(string) { return  "LeonardoDaVinci"; }
    string public TxHash_root = "genesis";

    string public ContractSource = "";
    string public CodeVersion = "v0.1";
    
    string public SecretKey_Pre = "";
    string public Name_New = "";
    string public TxHash_Pre = "";
    string public DigestCode_New = "";
    string public Image_New = "";
    string public Note_New = "";

    function getName() public view returns(string) { return name; }
    function getDigestCodeRoot() public view returns(string) { return DigestCode_root; }
    function getTxHashRoot() public view returns(string) { return TxHash_root; }
    function getImageRoot() public view returns(string) { return Image_root; }
    function getNoteRoot() public view returns(string) { return Note_root; }
    function getCodeVersion() public view returns(string) { return CodeVersion; }
    function getContractSource() public view returns(string) { return ContractSource; }

    function getSecretKeyPre() public view returns(string) { return SecretKey_Pre; }
    function getNameNew() public view returns(string) { return Name_New; }
    function getTxHashPre() public view returns(string) { return TxHash_Pre; }
    function getDigestCodeNew() public view returns(string) { return DigestCode_New; }
    function getImageNew() public view returns(string) { return Image_New; }
    function getNoteNew() public view returns(string) { return Note_New; }

    function setNewBlock(string _SecretKey_Pre, string _Name_New, string _TxHash_Pre, string _DigestCode_New, string _Image_New, string _Note_New )  returns (bool success) {
        SecretKey_Pre = _SecretKey_Pre;
        Name_New = _Name_New;
        TxHash_Pre = _TxHash_Pre;
        DigestCode_New = _DigestCode_New;
        Image_New = _Image_New;
        Note_New = _Note_New;
        emit setNewBlockEvent(SecretKey_Pre, Name_New, TxHash_Pre, DigestCode_New, Image_New, Note_New);
        return true;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
