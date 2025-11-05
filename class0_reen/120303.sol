





pragma solidity 0.5.7;






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













contract FrenchIco_Crowdsale is OwnablePayable, FrenchIco {

 using SafeMath for uint256;
 FrenchIco_Token public token;

  







    event TokensBuy(address beneficary, uint amount);
    event Copyright(string copyright);

   






    struct Investor {
	uint tokensBought;
    }
    mapping(address => Investor) public Investors;

   





    uint public endTime;
    uint public fundsCollected;

  






    constructor(string memory _name, string memory _symbol, uint _endTime) public {
        token = new FrenchIco_Token(_symbol, _name);
        endTime = _endTime;
        emit Copyright("Copyright FRENCHICO");

    }

  



    function() external payable {
        buyTokens();
    }


  



    function buyTokens() public payable isNotStoppedByFrenchIco  {
         require (msg.value>0,"empty");
         require (validAccess(msg.value), "Control Access Denied");
         require (now <= endTime,"ICO not running");
         token.mint(msg.sender,msg.value);
         Investors[msg.sender].tokensBought = Investors[msg.sender].tokensBought.add(msg.value);
         fundsCollected = fundsCollected.add(msg.value);
         _owner.transfer(address(this).balance);

         emit TokensBuy(msg.sender, msg.value);
    }


  




    function validAccess(uint value) public view returns(bool) {
        bool access;
        if (Fico.GetRole(msg.sender) <= 1 && Investors[msg.sender].tokensBought.add(value) <= Fico.GetMaxAmount()){access = true;}
        else if (Fico.GetRole(msg.sender) > 1){access = true;}
        else {access = false;}
        return access;
    }


}