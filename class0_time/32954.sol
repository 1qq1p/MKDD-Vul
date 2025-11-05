pragma solidity ^0.4.13;

contract RBInformationStore is Ownable {
    address public profitContainerAddress;
    address public companyWalletAddress;
    uint public etherRatioForOwner;
    address public multisig;

    function RBInformationStore(address _profitContainerAddress, address _companyWalletAddress, uint _etherRatioForOwner, address _multisig) {
        profitContainerAddress = _profitContainerAddress;
        companyWalletAddress = _companyWalletAddress;
        etherRatioForOwner = _etherRatioForOwner;
        multisig = _multisig;
    }

    function setProfitContainerAddress(address _address)  {
        require(multisig == msg.sender);
        if(_address != 0x0) {
            profitContainerAddress = _address;
        }
    }

    function setCompanyWalletAddress(address _address)  {
        require(multisig == msg.sender);
        if(_address != 0x0) {
            companyWalletAddress = _address;
        }
    }

    function setEtherRatioForOwner(uint _value)  {
        require(multisig == msg.sender);
        if(_value != 0) {
            etherRatioForOwner = _value;
        }
    }

    function changeMultiSig(address newAddress){
        require(multisig == msg.sender);
        multisig = newAddress;
    }

    function changeOwner(address newOwner){
        require(multisig == msg.sender);
        owner = newOwner;
    }
}




library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      revert();
    }
  }
}





