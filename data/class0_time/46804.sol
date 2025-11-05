pragma solidity ^0.4.23;





pragma solidity ^0.4.23;






pragma solidity ^0.4.23;







pragma solidity ^0.4.23;











contract DeploymentInfo {
  uint private deployed_on;

  constructor() public {
    deployed_on = block.number;
  }


  function getDeploymentBlock() public view returns (uint) {
    return deployed_on;
  }
}









pragma solidity ^0.4.23;





