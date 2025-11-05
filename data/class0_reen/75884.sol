pragma solidity 0.4.22;

contract DestructibleMiniMeToken is MiniMeToken {

  address terminator;

  function DestructibleMiniMeToken(
      address _tokenFactory,
      address _parentToken,
      uint _parentSnapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled,
      address _terminator
  ) public MiniMeToken(
      _tokenFactory,
      _parentToken,
      _parentSnapShotBlock,
      _tokenName,
      _decimalUnits,
      _tokenSymbol,
      _transfersEnabled
    ) {
        terminator = _terminator;
      }

  function recycle() public {
    require(msg.sender == terminator);
    selfdestruct(terminator);
  }
}
