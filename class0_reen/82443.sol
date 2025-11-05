pragma solidity ^0.4.17;

contract NovaAccessControl {
  mapping (address => bool) managers;
  address public cfoAddress;

  function NovaAccessControl() public {
    managers[msg.sender] = true;
  }

  modifier onlyManager() {
    require(managers[msg.sender]);
    _;
  }

  function setManager(address _newManager) external onlyManager {
    require(_newManager != address(0));
    managers[_newManager] = true;
  }

  function removeManager(address mangerAddress) external onlyManager {
    require(mangerAddress != msg.sender);
    managers[mangerAddress] = false;
  }

  function updateCfo(address newCfoAddress) external onlyManager {
    require(newCfoAddress != address(0));
    cfoAddress = newCfoAddress;
  }
}
