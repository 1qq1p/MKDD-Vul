pragma solidity ^0.4.19;

contract CaData is ADM312, ERC721 {
    
    function CaData() public {
        COO = msg.sender;
        CTO = msg.sender;
        CFO = msg.sender;
        createCustomAtom(0,0,4,0,0,0,0);
    }
    
    function kill() external
	{
	    require(msg.sender == COO);
		selfdestruct(msg.sender);
	}
    
    function() public payable{}
    
    uint public randNonce  = 0;
    
    struct Atom 
    {
      uint64   dna;
      uint8    gen;
      uint8    lev;
      uint8    cool;
      uint32   sons;
      uint64   fath;
	  uint64   moth;
	  uint128  isRent;
	  uint128  isBuy;
	  uint32   isReady;
    }
    
    Atom[] public atoms;
    
    mapping (uint64  => bool) public dnaExist;
    mapping (address => bool) public bonusReceived;
    mapping (address => uint) public ownerAtomsCount;
    mapping (uint => address) public atomOwner;
    
    event NewWithdraw(address sender, uint balance);

    
    
    
    function createCustomAtom(uint64 _dna, uint8 _gen, uint8 _lev, uint8 _cool, uint128 _isRent, uint128 _isBuy, uint32 _isReady) public onlyAdmin {
        require(dnaExist[_dna]==false && _cool+_lev>=4);
        Atom memory newAtom = Atom(_dna, _gen, _lev, _cool, 0, 2**50, 2**50, _isRent, _isBuy, _isReady);
        uint id = atoms.push(newAtom) - 1;
        atomOwner[id] = msg.sender;
        ownerAtomsCount[msg.sender]++;
        dnaExist[_dna] = true;
    }
    
    function withdrawBalance() public payable onlyAdmin {
		NewWithdraw(msg.sender, address(this).balance);
        CFO.transfer(address(this).balance);
    }
    
    
    
    function incRandNonce() external onlyContract {
        randNonce++;
    }
    
    function setDnaExist(uint64 _dna, bool _newDnaLocking) external onlyContractAdmin {
        dnaExist[_dna] = _newDnaLocking;
    }
    
    function setBonusReceived(address _add, bool _newBonusLocking) external onlyContractAdmin {
        bonusReceived[_add] = _newBonusLocking;
    }
    
    function setOwnerAtomsCount(address _owner, uint _newCount) external onlyContract {
        ownerAtomsCount[_owner] = _newCount;
    }
    
    function setAtomOwner(uint _atomId, address _owner) external onlyContract {
        atomOwner[_atomId] = _owner;
    }
    
    
    
    function pushAtom(uint64 _dna, uint8 _gen, uint8 _lev, uint8 _cool, uint32 _sons, uint64 _fathId, uint64 _mothId, uint128 _isRent, uint128 _isBuy, uint32 _isReady) external onlyContract returns (uint id) {
        Atom memory newAtom = Atom(_dna, _gen, _lev, _cool, _sons, _fathId, _mothId, _isRent, _isBuy, _isReady);
        id = atoms.push(newAtom) -1;
    }
	
	function setAtomDna(uint _atomId, uint64 _dna) external onlyAdmin {
        atoms[_atomId].dna = _dna;
    }
	
	function setAtomGen(uint _atomId, uint8 _gen) external onlyAdmin {
        atoms[_atomId].gen = _gen;
    }
    
    function setAtomLev(uint _atomId, uint8 _lev) external onlyContract {
        atoms[_atomId].lev = _lev;
    }
    
    function setAtomCool(uint _atomId, uint8 _cool) external onlyContract {
        atoms[_atomId].cool = _cool;
    }
    
    function setAtomSons(uint _atomId, uint32 _sons) external onlyContract {
        atoms[_atomId].sons = _sons;
    }
    
    function setAtomFath(uint _atomId, uint64 _fath) external onlyContract {
        atoms[_atomId].fath = _fath;
    }
    
    function setAtomMoth(uint _atomId, uint64 _moth) external onlyContract {
        atoms[_atomId].moth = _moth;
    }
    
    function setAtomIsRent(uint _atomId, uint128 _isRent) external onlyContract {
        atoms[_atomId].isRent = _isRent;
    }
    
    function setAtomIsBuy(uint _atomId, uint128 _isBuy) external onlyContract {
        atoms[_atomId].isBuy = _isBuy;
    }
    
    function setAtomIsReady(uint _atomId, uint32 _isReady) external onlyContractAdmin {
        atoms[_atomId].isReady = _isReady;
    }
    
    
    
    mapping (uint => address) tokenApprovals;
    
    function totalSupply() public view returns (uint256 total){
  	    return atoms.length;
  	}
  	
  	function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerAtomsCount[_owner];
    }
    
    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        return atomOwner[_tokenId];
    }
      
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        atoms[_tokenId].isBuy  = 0;
        atoms[_tokenId].isRent = 0;
        ownerAtomsCount[_to]++;
        ownerAtomsCount[_from]--;
        atomOwner[_tokenId] = _to;
        Transfer(_from, _to, _tokenId);
    }
  
    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == atomOwner[_tokenId]);
        _transfer(msg.sender, _to, _tokenId);
    }
    
    function approve(address _to, uint256 _tokenId) public {
        require(msg.sender == atomOwner[_tokenId]);
        tokenApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }
    
    function takeOwnership(uint256 _tokenId) public {
        require(tokenApprovals[_tokenId] == msg.sender);
        _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
    }
    
}
