pragma solidity 0.5.1;











contract Authorizable {

    address[] authorizers;
    mapping(address => uint) authorizerIndex;

    


    modifier onlyAuthorized {
        require(isAuthorized(msg.sender));
        _;
    }

    


    constructor() public {
        authorizers.length = 2;
        authorizers[1] = msg.sender;
        authorizerIndex[msg.sender] = 1;
    }

    




    function getAuthorizer(uint authorizerIndex) external view returns(address) {
        return address(authorizers[authorizerIndex + 1]);
    }

    




    function isAuthorized(address _addr) public view returns(bool) {
        return authorizerIndex[_addr] > 0;
    }

    



    function addAuthorized(address _addr) external onlyAuthorized {
        authorizerIndex[_addr] = authorizers.length;
        authorizers.length++;
        authorizers[authorizers.length - 1] = _addr;
    }

}







