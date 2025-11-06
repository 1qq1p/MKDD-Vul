pragma solidity 0.4.24;
















pragma solidity 0.4.24;


contract AugmintTokenInterface is Restricted, ERC20Interface {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    bytes32 public peggedSymbol;
    uint8 public decimals;

    uint public totalSupply;
    mapping(address => uint256) public balances; 
    mapping(address => mapping (address => uint256)) public allowed; 

    TransferFeeInterface public feeAccount;
    mapping(bytes32 => bool) public delegatedTxHashesUsed; 

    event TransferFeesChanged(uint transferFeePt, uint transferFeeMin, uint transferFeeMax);
    event Transfer(address indexed from, address indexed to, uint amount);
    event AugmintTransfer(address indexed from, address indexed to, uint amount, string narrative, uint fee);
    event TokenIssued(uint amount);
    event TokenBurned(uint amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address to, uint value) external returns (bool); 
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);

    function delegatedTransfer(address from, address to, uint amount, string narrative,
                                    uint maxExecutorFeeInToken, 
                                    bytes32 nonce, 
                                    
                                    bytes signature,
                                    uint requestedExecutorFeeInToken 
                                ) external;

    function delegatedTransferAndNotify(address from, TokenReceiver target, uint amount, uint data,
                                    uint maxExecutorFeeInToken, 
                                    bytes32 nonce, 
                                    
                                    bytes signature,
                                    uint requestedExecutorFeeInToken 
                                ) external;

    function increaseApproval(address spender, uint addedValue) external;
    function decreaseApproval(address spender, uint subtractedValue) external;

    function issueTo(address to, uint amount) external; 
    function burn(uint amount) external;

    function transferAndNotify(TokenReceiver target, uint amount, uint data) external;

    function transferWithNarrative(address to, uint256 amount, string narrative) external;
    function transferFromWithNarrative(address from, address to, uint256 amount, string narrative) external;

    function setName(string _name) external;
    function setSymbol(string _symbol) external;

    function allowance(address owner, address spender) external view returns (uint256 remaining);

    function balanceOf(address who) external view returns (uint);


}













library ECRecovery {

  




  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    
    if (sig.length != 65) {
      return (address(0));
    }

    
    
    
    
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
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

  




  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    
    
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}














pragma solidity 0.4.24;





