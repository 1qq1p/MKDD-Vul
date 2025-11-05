pragma solidity ^0.4.25;







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








contract Pauser is Ownable {

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    mapping (address => bool) private pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return pausers[account];
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function renouncePauser(address account) public {
        require(msg.sender == account || isOwner());
        _removePauser(account);
    }

    function _addPauser(address account) internal {
        pausers[account] = true;
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        pausers[account] = false;
        emit PauserRemoved(account);
    }
}




