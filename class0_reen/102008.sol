contract AirSwap {
    function fill(
      address makerAddress,
      uint makerAmount,
      address makerToken,
      address takerAddress,
      uint takerAmount,
      address takerToken,
      uint256 expiration,
      uint256 nonce,
      uint8 v,
      bytes32 r,
      bytes32 s
    ) payable {}
}

contract Dex {
  using SafeMath for uint256;

  AirSwap constant airswap = AirSwap(0x8fd3121013A07C57f0D69646E86E7a4880b467b7);
  Pool constant pool = Pool(0xE00c09fEdD3d3Ed09e2D6F6F6E9B1597c1A99bc8);
  
  function fill(
    address masternode,
    address makerAddress,
    uint256 makerAmount,
    address makerToken,
    uint256 takerAmount,
    address takerToken,
    uint256 expiration,
    uint256 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public payable {
    
    require(takerToken == address(0));
    
    
    require(makerToken != address(0));
    
    
    
    
    
    uint256[] memory settings = new uint256[](3);
    
    
    settings[0] = takerAmount / 100;

    
    settings[1] = msg.value.sub(settings[0]);
    
    
    settings[2] = makerAddress.balance;
      
    
    require(settings[1] == takerAmount);
    
    
    airswap.fill.value(settings[1])(
      makerAddress,
      makerAmount,
      makerToken,
      msg.sender,
      settings[1],
      takerToken,
      expiration,
      nonce,
      v,
      r,
      s
    );
    
    
    require(makerAddress.balance == (settings[2].add(settings[1])));

    
    if (settings[0] != 0) {
      pool.contribute.value(settings[0])(masternode, msg.sender);
    }
  }
}