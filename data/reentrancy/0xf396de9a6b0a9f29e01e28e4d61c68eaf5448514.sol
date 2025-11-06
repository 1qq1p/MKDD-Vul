pragma solidity ^0.5.0;
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));
        role.bearer[account] = true;
    }
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));
        role.bearer[account] = false;
    }
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}
pragma solidity ^0.5.0;
contract SignerRole {
    using Roles for Roles.Role;
    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);
    Roles.Role private _signers;
    constructor () internal {
        _addSigner(msg.sender);
    }
    modifier onlySigner() {
        require(isSigner(msg.sender));
        _;
    }
    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }
    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }
    function renounceSigner() public {
        _removeSigner(msg.sender);
    }
    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }
    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}
pragma solidity ^0.5.0;
library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (signature.length != 65) {
            return (address(0));
        }
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
pragma solidity ^0.5.0;
contract SignatureBouncer is SignerRole {
    using ECDSA for bytes32;
    uint256 private constant _METHOD_ID_SIZE = 4;
    uint256 private constant _SIGNATURE_SIZE = 96;
    constructor () internal {
    }
    modifier onlyValidSignature(bytes memory signature) {
        require(_isValidSignature(msg.sender, signature));
        _;
    }
    modifier onlyValidSignatureAndMethod(bytes memory signature) {
        require(_isValidSignatureAndMethod(msg.sender, signature));
        _;
    }
    modifier onlyValidSignatureAndData(bytes memory signature) {
        require(_isValidSignatureAndData(msg.sender, signature));
        _;
    }
    function _isValidSignature(address account, bytes memory signature) internal view returns (bool) {
        return _isValidDataHash(keccak256(abi.encodePacked(address(this), account)), signature);
    }
    function _isValidSignatureAndMethod(address account, bytes memory signature) internal view returns (bool) {
        bytes memory data = new bytes(_METHOD_ID_SIZE);
        for (uint i = 0; i < data.length; i++) {
            data[i] = msg.data[i];
        }
        return _isValidDataHash(keccak256(abi.encodePacked(address(this), account, data)), signature);
    }
    function _isValidSignatureAndData(address account, bytes memory signature) internal view returns (bool) {
        require(msg.data.length > _SIGNATURE_SIZE);
        bytes memory data = new bytes(msg.data.length - _SIGNATURE_SIZE);
        for (uint i = 0; i < data.length; i++) {
            data[i] = msg.data[i];
        }
        return _isValidDataHash(keccak256(abi.encodePacked(address(this), account, data)), signature);
    }
    function _isValidDataHash(bytes32 hash, bytes memory signature) internal view returns (bool) {
        address signer = hash.toEthSignedMessageHash().recover(signature);
        return signer != address(0) && isSigner(signer);
    }
}
pragma solidity ^0.5.0;
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
pragma solidity ^0.5.0;
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}
pragma solidity ^0.5.0;
contract ERC20Burnable is ERC20 {
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}
pragma solidity ^0.5.0;
library SafeERC20 {
    using SafeMath for uint256;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}
pragma solidity ^0.5.0;
contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.5.0;
contract DutchAuction is SignatureBouncer, Ownable {
    using SafeERC20 for ERC20Burnable;
    event BidSubmission(address indexed sender, uint256 amount);
    uint constant public WAITING_PERIOD = 0; 
    ERC20Burnable public token;
    address public ambix;
    address payable public wallet;
    uint public maxTokenSold;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    modifier isValidPayload() {
        require(msg.data.length == 4 || msg.data.length == 164);
        _;
    }
    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }
    constructor(address payable _wallet, uint _maxTokenSold, uint _ceiling, uint _priceFactor)
        public
    {
        require(_wallet != address(0) && _ceiling > 0 && _priceFactor > 0);
        wallet = _wallet;
        maxTokenSold = _maxTokenSold;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }
    function setup(ERC20Burnable _token, address _ambix)
        public
        onlyOwner
        atStage(Stages.AuctionDeployed)
    {
        require(_token != ERC20Burnable(0) && _ambix != address(0));
        token = _token;
        ambix = _ambix;
        require(token.balanceOf(address(this)) == maxTokenSold);
        stage = Stages.AuctionSetUp;
    }
    function startAuction()
        public
        onlyOwner
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }
    function bid(bytes calldata signature)
        external
        payable
        isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        onlyValidSignature(signature)
        returns (uint amount)
    {
        require(msg.value > 0);
        amount = msg.value;
        address payable receiver = msg.sender;
        uint maxWei = maxTokenSold * calcTokenPrice() / 10**9 - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;
        if (amount > maxWei) {
            amount = maxWei;
            receiver.transfer(msg.value - amount);
        }
        (bool success,) = wallet.call.value(amount)("");
        require(success);
        bids[receiver] += amount;
        totalReceived += amount;
        emit BidSubmission(receiver, amount);
        if (amount == maxWei)
            finalizeAuction();
    }
    function claimTokens()
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        address receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**9 / finalPrice;
        bids[receiver] = 0;
        token.safeTransfer(receiver, tokenCount);
    }
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**9 / maxTokenSold + 1;
    }
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;
        finalPrice = totalReceived == ceiling ? calcTokenPrice() : calcStopPrice();
        uint soldTokens = totalReceived * 10**9 / finalPrice;
        if (totalReceived == ceiling) {
            token.safeTransfer(ambix, maxTokenSold - soldTokens);
        } else {
            token.burn(maxTokenSold - soldTokens);
        }
        endTime = now;
    }
}