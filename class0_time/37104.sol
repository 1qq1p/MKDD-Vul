pragma solidity ^0.4.24;




contract Pausable {

    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    


    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    


    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

   


    function _pause() internal whenNotPaused {
        paused = true;
        
        emit Pause(now);
    }

    


    function _unpause() internal whenPaused {
        paused = false;
        
        emit Unpause(now);
    }

}





interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




