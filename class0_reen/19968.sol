pragma solidity ^0.4.17;

contract NovaLabInterface {
  function bornStar() external returns(uint star) {}
  function bornMeteoriteNumber() external returns(uint mNumber) {}
  function bornMeteorite() external returns(uint mQ) {}
  function mergeMeteorite(uint totalQuality) external returns(bool isSuccess, uint finalMass) {}
}
