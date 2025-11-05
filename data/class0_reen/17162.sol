

pragma solidity ^0.4.25;




contract IntermediateResultsStorage is ResolverClient, DaoConstants {
    using DaoStructs for DaoStructs.IntermediateResults;

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_INTERMEDIATE_RESULTS, _resolver));
    }

    
    
    
    
    
    
    
    mapping (bytes32 => DaoStructs.IntermediateResults) allIntermediateResults;

    function getIntermediateResults(bytes32 _key)
        public
        view
        returns (
            address _countedUntil,
            uint256 _currentForCount,
            uint256 _currentAgainstCount,
            uint256 _currentSumOfEffectiveBalance
        )
    {
        _countedUntil = allIntermediateResults[_key].countedUntil;
        _currentForCount = allIntermediateResults[_key].currentForCount;
        _currentAgainstCount = allIntermediateResults[_key].currentAgainstCount;
        _currentSumOfEffectiveBalance = allIntermediateResults[_key].currentSumOfEffectiveBalance;
    }

    function resetIntermediateResults(bytes32 _key)
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_SPECIAL_VOTING_CLAIMS]));
        allIntermediateResults[_key].countedUntil = address(0x0);
    }

    function setIntermediateResults(
        bytes32 _key,
        address _countedUntil,
        uint256 _currentForCount,
        uint256 _currentAgainstCount,
        uint256 _currentSumOfEffectiveBalance
    )
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_SPECIAL_VOTING_CLAIMS]));
        allIntermediateResults[_key].countedUntil = _countedUntil;
        allIntermediateResults[_key].currentForCount = _currentForCount;
        allIntermediateResults[_key].currentAgainstCount = _currentAgainstCount;
        allIntermediateResults[_key].currentSumOfEffectiveBalance = _currentSumOfEffectiveBalance;
    }
}


library MathHelper {

  using SafeMath for uint256;

  function max(uint256 a, uint256 b) internal pure returns (uint256 _max){
      _max = b;
      if (a > b) {
          _max = a;
      }
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256 _min){
      _min = b;
      if (a < b) {
          _min = a;
      }
  }

  function sumNumbers(uint256[] _numbers) internal pure returns (uint256 _sum) {
      for (uint256 i=0;i<_numbers.length;i++) {
          _sum = _sum.add(_numbers[i]);
      }
  }
}

