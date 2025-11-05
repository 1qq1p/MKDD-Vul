pragma solidity ^0.4.21;
    
   
   
   
   
   
   
   
   
   
   
    
  library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
      return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
      
      uint256 c = a / b;
      
      return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
  }

   
   

contract TokenBase is ERC20Interface {

      using SafeMath for uint;

      string public constant symbol = "DELTA";
      string public constant name = "DELTA token";
      uint8 public constant decimals = 18; 
           
      uint256 public constant maxTokens = (2**32-1)*10**18; 
      uint256 public constant ownerSupply = maxTokens*25/100;
      uint256 _totalSupply = ownerSupply;              

      
      
      bool public migrationAllowed = false;

      
      address public migrationAddress;

      
      uint256 public totalMigrated = 0; 
      
      
      address public owner;
   
      
      mapping(address => uint256) balances;
   
      
      mapping(address => mapping (address => uint256)) allowed;

      
      mapping(address => uint256) public orders_sell_amount;

      
      mapping(address => uint256) public orders_sell_price;

      
      address[] public orders_sell_list;

      
      event Orders_sell(address indexed _from, address indexed _to, uint256 _amount, uint256 _price, uint256 _seller_money, uint256 _buyer_money);
   
      
      modifier onlyOwner() {
          if (msg.sender != owner) {
              throw;
          }
          _;
      }

      
      function migrate(uint256 _value) external {
          require(migrationAllowed);
          require(migrationAddress != 0x0);
          require(_value > 0);
          require(_value <= balances[msg.sender]);

          balances[msg.sender] = balances[msg.sender].sub(_value);
          _totalSupply = _totalSupply.sub(_value);
          totalMigrated = totalMigrated.add(_value);

          MigrationAgent(migrationAddress).migrateFrom(msg.sender, _value);
      }  
      
      function configureMigrate(bool _migrationAllowed, address _migrationAddress) onlyOwner {
          migrationAllowed = _migrationAllowed;
          migrationAddress = _migrationAddress;
      }

  }
