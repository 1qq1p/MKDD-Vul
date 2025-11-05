pragma solidity 0.5.0;








contract AuthorisedContractBase is HorizonContractBase {

    


    mapping(address => bool) public authorised;

    


    event AuthorisationChanged(address indexed who, bool isAuthorised);

    


    constructor() public {
        
        setAuthorised(msg.sender, true);
    } 

    





    function setAuthorised(address who, bool isAuthorised) public onlyOwner {
        authorised[who] = isAuthorised;
        emit AuthorisationChanged(who, isAuthorised);
    }

    





    function isAuthorised(address who) public view returns (bool) {
        return authorised[who];
    }

    


    modifier onlyAuthorised() {
        require(isAuthorised(msg.sender), "Access denied.");
        _;
    }
}








library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

















