pragma solidity ^0.4.24;






library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function mul(int256 a, int256 b) internal pure returns (int256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); 

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); 
        require(!(b == -1 && a == INT256_MIN)); 

        int256 c = a / b;

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    


    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}





contract HRS is ERC20, ERC20Detailed, Ownable, ReentrancyGuard  {
   using SafeMath for uint256;
   
   mapping (address => bool) status; 
   
   
    address private _walletP;
    
    address private _walletN;
    
    
    
    
    uint256 private _rate;
    
    uint256 private _x;
    
    uint256 private _y;
    
    uint256 private _weiRaised;
    
    


    constructor () public ERC20Detailed("HYDROSTANDART", "HRS", 18, 20000000
    ) {
        _mint(msg.sender, initSupply());
    }

   





    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }
    
   





    function burn(address to, uint256 value) public onlyOwner returns (bool) {
        _burn(to, value);
        return true;
    }
   



    function CheckStatus(address account) public view returns (bool) {
        require(account != address(0));
        bool currentStatus = status[account];
        return currentStatus;
    }
    
    



    function ChangeStatus(address account) public  onlyOwner {
        require(account != address(0));
        bool currentStatus1 = status[account];
       status[account] = (currentStatus1 == true) ? false : true;
    }

   





    function () external payable {
        buyTokens(msg.sender, msg.value);
        }
    function buyTokens(address beneficiary, uint256 weiAmount) public nonReentrant payable {
        require(beneficiary != address(0) && beneficiary !=_walletP && beneficiary !=_walletN);
        require(weiAmount != 0);
        require(_walletP != 0);
        require(_walletN != 0);
        require(CheckStatus(beneficiary) != true);
        
        
        uint256 tokens = weiAmount.div(_y).mul(_x).mul(_rate);
        
        address CurrentFundWallet = (balanceOf(_walletP) > balanceOf(_walletN) == true) ? _walletP : _walletN;
        
        require(balanceOf(CurrentFundWallet) > tokens);
        
        _weiRaised = _weiRaised.add(weiAmount);
        
       _transfer(CurrentFundWallet, beneficiary, tokens);
       
       CurrentFundWallet.transfer(weiAmount);
    }
  
    


    function setRate(uint256 rate) public onlyOwner  {
        require(rate > 1);
        _rate = rate;
    }
    


    function setX(uint256 x) public onlyOwner  {
        require(x >= 1);
        _x = x;
    }
    


    function setY(uint256 y) public onlyOwner  {
        require(y >= 1);
        _y = y;
    }
    


    function setPositivWallet(address PositivWallet) public onlyOwner  {
        _walletP = PositivWallet;
    } 
    
    


    function PositivWallet() public view returns (address) {
        return _walletP;
    }
    


    function setNegativWallet(address NegativWallet) public onlyOwner  {
        _walletN = NegativWallet;
    } 
    
    


    function NegativWallet() public view returns (address) {
        return _walletN;
    }
    


    function Rate() public view returns (uint256) {
        return _rate;
    }
    


    function X() public view returns (uint256) {
        return _x;
    }
    


    function Y() public view returns (uint256) {
        return _y;
    }
    


    function WeiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    
}