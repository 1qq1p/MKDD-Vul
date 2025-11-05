pragma solidity 0.5.3;







contract Custodian is Stoppable, HasOwners, MerkleProof, Ledger, Depositing, Withdrawing, Versioned {

  address public constant ETH = address(0x0);
  uint public constant confirmationDelay = 5;
  uint public constant visibilityDelay = 3;
  uint public nonceGenerator = 0;

  address public operator;
  address public registry;

  constructor(address[] memory _owners, address _registry, address _operator, uint _submissionInterval, string memory _version)
    HasOwners(_owners)
    Versioned(_version)
    public validAddress(_registry) validAddress(_operator)
  {
    operator = _operator;
    registry = _registry;
    submissionInterval = _submissionInterval;
  }

  
  function transfer(uint quantity, address asset, address account) internal {
    asset == ETH ?
      require(address(uint160(account)).send(quantity), "failed to transfer ether") : 
      require(Token(asset).transfer(account, quantity), "failed to transfer token");
  }

  








  
  
  function recover(bytes32 hash, bytes memory signature) private pure returns (address) {
    bytes32 r; bytes32 s; uint8 v;
    if (signature.length != 65) return (address(0)); 

    
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }

    
    if (v < 27) v += 27;

    
    return (v != 27 && v != 28) ? (address(0)) : ecrecover(hash, v, r, s);
  }

  function verifySignedBy(bytes32 hash, bytes memory signature, address signer) internal pure {
    require(recover(hash, signature) == signer, "failed to verify signature");
  }

  

  mapping (bytes32 => bool) public deposits;

  modifier validToken(address value) { require(value != ETH, "value must be a valid ERC20 token address"); _; }

  function () external payable { deposit(msg.sender, ETH, msg.value); }
  function depositEther() external payable { deposit(msg.sender, ETH, msg.value); }

  
  function depositToken(address token, uint quantity) external validToken(token) {
    uint balanceBefore = Token(token).balanceOf(address(this));
    require(Token(token).transferFrom(msg.sender, address(this), quantity), "failure to transfer quantity from token");
    uint balanceAfter = Token(token).balanceOf(address(this));
    require(balanceAfter - balanceBefore == quantity, "bad Token; transferFrom erroneously reported of successful transfer");
    deposit(msg.sender, token, quantity);
  }

  function deposit(address account, address asset, uint quantity) private whenOn {
    uint nonce = ++nonceGenerator;
    uint designatedGblock = currentGblockNumber + visibilityDelay;
    DepositCommitmentRecord memory record = toDepositCommitmentRecord(account, asset, quantity, nonce, designatedGblock);
    deposits[record.hash] = true;
    emit Deposited(address(this), account, asset, quantity, nonce, designatedGblock);
  }

  function reclaimDeposit(
    address[] calldata addresses,
    uint[] calldata uints,
    bytes32[] calldata leaves,
    uint[] calldata indexes,
    bytes calldata predecessor,
    bytes calldata successor
  ) external {
    ProofOfExclusionOfDeposit memory proof = extractProofOfExclusionOfDeposit(addresses, uints, leaves, indexes, predecessor, successor);
    DepositCommitmentRecord memory record = proof.excluded;
    require(record.account == msg.sender, "claimant must be the original depositor");
    require(currentGblockNumber > record.designatedGblock && record.designatedGblock != 0, "designated gblock is unconfirmed or unknown");

    Gblock memory designatedGblock = gblocksByNumber[record.designatedGblock];
    require(proveIsExcludedFromDeposits(designatedGblock.depositsRoot, proof), "failed to proof exclusion of deposit");

    _reclaimDeposit_(record);
  }

  function proveIsExcludedFromDeposits(bytes32 root, ProofOfExclusionOfDeposit memory proof) private pure returns (bool) {
    return
      proof.successor.index == proof.predecessor.index + 1 && 
      verifyIncludedAtIndex(proof.predecessor.proof, root, proof.predecessor.leaf, proof.predecessor.index) &&
      verifyIncludedAtIndex(proof.successor.proof, root, proof.successor.leaf, proof.successor.index);
  }

  function reclaimDepositOnHalt(address asset, uint quantity, uint nonce, uint designatedGblock) external whenOff {
    DepositCommitmentRecord memory record = toDepositCommitmentRecord(msg.sender, asset, quantity, nonce, designatedGblock);
    require(record.designatedGblock >= currentGblockNumber, "designated gblock is already confirmed; use exitOnHalt instead");
    _reclaimDeposit_(record);
  }

  function _reclaimDeposit_(DepositCommitmentRecord memory record) private {
    require(deposits[record.hash], "unknown deposit");
    delete deposits[record.hash];
    transfer(record.quantity, record.asset, record.account);
    emit DepositReclaimed(address(this), record.account, record.asset, record.quantity, record.nonce);
  }

  function extractProofOfExclusionOfDeposit(
    address[] memory addresses,
    uint[] memory uints,
    bytes32[] memory leaves,
    uint[] memory indexes,
    bytes memory predecessor,
    bytes memory successor
  ) private view returns (ProofOfExclusionOfDeposit memory result) {
    result.excluded = extractDepositCommitmentRecord(addresses, uints);
    result.predecessor = ProofOfInclusionAtIndex(leaves[0], indexes[0], predecessor);
    result.successor = ProofOfInclusionAtIndex(leaves[1], indexes[1], successor);
  }

  function extractDepositCommitmentRecord(address[] memory addresses, uint[] memory uints) private view returns (DepositCommitmentRecord memory) {
    return toDepositCommitmentRecord(
      addresses[1],
      addresses[2],
      uints[0],
      uints[1],
      uints[2]
    );
  }

  function toDepositCommitmentRecord(
    address account,
    address asset,
    uint quantity,
    uint nonce,
    uint designatedGblock
  ) private view returns (DepositCommitmentRecord memory result) {
    result.account = account;
    result.asset = asset;
    result.quantity = quantity;
    result.nonce = nonce;
    result.designatedGblock = designatedGblock;
    result.hash = keccak256(abi.encodePacked(
      address(this),
      account,
      asset,
      quantity,
      nonce,
      designatedGblock
    ));
  }

  event Deposited(address indexed custodian, address indexed account, address indexed asset, uint quantity, uint nonce, uint designatedGblock);
  event DepositReclaimed(address indexed custodian, address indexed account, address indexed asset, uint quantity, uint nonce);

  struct ProofOfInclusionAtIndex { bytes32 leaf; uint index; bytes proof; }
  struct ProofOfExclusionOfDeposit { DepositCommitmentRecord excluded; ProofOfInclusionAtIndex predecessor; ProofOfInclusionAtIndex successor; }

  

  mapping (bytes32 => bool) public withdrawn;
  mapping (bytes32 => ExitClaim) private exitClaims;
  mapping (address => mapping (address => bool)) public exited; 

  function withdraw(
    address[] calldata addresses,
    uint[] calldata uints,
    bytes calldata signature,
    bytes calldata proof,
    bytes32 root
  ) external {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "withdrawer must be entry's account");
    require(entry.entryType == EntryType.Withdrawal, "entry must be of type Withdrawal");
    require(proveInConfirmedWithdrawals(proof, root, entry.hash), "invalid entry proof");
    require(!withdrawn[entry.hash], "entry already withdrawn");
    withdrawn[entry.hash] = true;
    transfer(entry.quantity, entry.asset, entry.account);
    emit Withdrawn(entry.hash, entry.account, entry.asset, entry.quantity);
  }

  function claimExit(
    address[] calldata addresses,
    uint[] calldata uints,
    bytes calldata signature,
    bytes calldata proof,
    bytes32 root
  ) external whenOn {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "claimant must be entry's account");
    require(!hasExited(entry.account, entry.asset), "previously exited");
    require(proveInConfirmedBalances(proof, root, entry.hash), "invalid balance proof");

    uint confirmationThreshold = currentGblockNumber + confirmationDelay;
    exitClaims[entry.hash] = ExitClaim(entry, confirmationThreshold);
    emit ExitClaimed(entry.hash, entry.account, entry.asset, entry.balance, entry.timestamp, confirmationThreshold);
  }

  function exit(bytes32 entryHash, bytes calldata proof, bytes32 root) external whenOn {
    ExitClaim memory claim = exitClaims[entryHash];
    require(canExit(entryHash), "no prior claim found to withdraw OR balances are yet to be confirmed");
    require(proveInUnconfirmedBalances(proof, root, entryHash), "invalid balance proof");
    delete exitClaims[entryHash];
    _exit_(claim.entry);
  }

  function exitOnHalt(
    address[] calldata addresses,
    uint[] calldata uints,
    bytes calldata signature,
    bytes calldata proof,
    bytes32 root
  ) external whenOff {
    Entry memory entry = extractEntry(addresses, uints);
    verifySignedBy(entry.hash, signature, operator);
    require(entry.account == msg.sender, "claimant must be entry's account");
    require(proveInConfirmedBalances(proof, root, entry.hash), "invalid balance proof");
    _exit_(entry);
  }

  function _exit_(Entry memory entry) private {
    require(!hasExited(entry.account, entry.asset), "previously exited");
    exited[entry.account][entry.asset] = true;
    transfer(entry.balance, entry.asset, entry.account);
    emit Exited(entry.account, entry.asset, entry.balance);
  }

  function hasExited(address account, address asset) public view returns (bool) { return exited[account][asset]; }

  function canExit(bytes32 entryHash) public view returns (bool) {
    return
      exitClaims[entryHash].confirmationThreshold != 0 &&  
      currentGblockNumber >= exitClaims[entryHash].confirmationThreshold;
  }

  event ExitClaimed(bytes32 hash, address indexed account, address indexed asset, uint quantity, uint timestamp, uint confirmationThreshold);
  event Exited(address indexed account, address indexed asset, uint quantity);
  event Withdrawn(bytes32 hash, address indexed account, address indexed asset, uint quantity);

  struct ExitClaim { Entry entry; uint confirmationThreshold; }

  

  uint public currentGblockNumber;
  mapping(uint => Gblock) public gblocksByNumber;
  mapping(bytes32 => uint) public gblocksByDepositsRoot;
  mapping(bytes32 => uint) public gblocksByWithdrawalsRoot;
  mapping(bytes32 => uint) public gblocksByBalancesRoot;
  uint public submissionInterval;
  uint public submissionBlock = block.number;

  function canSubmit() public view returns (bool) { return block.number >= submissionBlock; }

  function submit(uint gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot) external whenOn {
    require(canSubmit(), "cannot submit yet");
    require(msg.sender == operator, "submitter must be the operator");
    require(gblockNumber == currentGblockNumber + 1, "gblock must be the next in sequence");
    Gblock memory gblock = Gblock(gblockNumber, withdrawalsRoot, depositsRoot, balancesRoot);
    gblocksByNumber[gblockNumber] = gblock;
    gblocksByDepositsRoot[depositsRoot] = gblockNumber;
    gblocksByWithdrawalsRoot[withdrawalsRoot] = gblockNumber;
    gblocksByBalancesRoot[balancesRoot] = gblockNumber;
    currentGblockNumber = gblockNumber;
    submissionBlock = block.number + submissionInterval;
    emit Submitted(gblockNumber, withdrawalsRoot, depositsRoot, balancesRoot);
  }

  function proveInConfirmedWithdrawals(bytes memory proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return isConfirmedWithdrawals(root) && verifyIncluded(proof, root, entryHash);
  }

  function proveInConfirmedBalances(bytes memory proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return
      root == gblocksByNumber[currentGblockNumber - 1 ].balancesRoot &&
      verifyIncluded(proof, root, entryHash);
  }

  function proveInUnconfirmedBalances(bytes memory proof, bytes32 root, bytes32 entryHash) public view returns (bool) {
    return
      root == gblocksByNumber[currentGblockNumber ].balancesRoot &&
      verifyIncluded(proof, root, entryHash);
  }

  function isConfirmedWithdrawals(bytes32 root) public view returns (bool) { return isConfirmedGblock(gblocksByWithdrawalsRoot[root]); }
  function isUnconfirmedWithdrawals(bytes32 root) public view returns (bool) { return gblocksByWithdrawalsRoot[root] == currentGblockNumber; }
  function includesWithdrawals(bytes32 root) public view returns (bool) { return gblocksByWithdrawalsRoot[root] != 0; }

  function isUnconfirmedBalances(bytes32 root) public view returns (bool) { return gblocksByBalancesRoot[root] == currentGblockNumber; }

  function isConfirmedGblock(uint number) public view returns (bool) { return 0 < number && number < currentGblockNumber; }

  event Submitted(uint gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot);

  struct Gblock { uint number; bytes32 withdrawalsRoot; bytes32 depositsRoot; bytes32 balancesRoot; }

  
}
