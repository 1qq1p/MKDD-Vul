pragma solidity ^0.4.21;






contract StrikersBase is ERC721Token("CryptoStrikers", "STRK") {

  
  event CardMinted(uint256 cardId);

  
  struct Card {
    
    
    
    uint32 mintTime;

    
    uint8 checklistId;

    
    
    
    uint16 serialNumber;
  }

  

  
  Card[] public cards;

  
  
  
  
  mapping (uint8 => uint16) public mintedCountForChecklistId;

  
  StrikersChecklist public strikersChecklist;

  

  
  
  
  
  function cardAndChecklistIdsForOwner(address _owner) external view returns (uint256[], uint8[]) {
    uint256[] memory cardIds = ownedTokens[_owner];
    uint256 cardCount = cardIds.length;
    uint8[] memory checklistIds = new uint8[](cardCount);

    for (uint256 i = 0; i < cardCount; i++) {
      uint256 cardId = cardIds[i];
      checklistIds[i] = cards[cardId].checklistId;
    }

    return (cardIds, checklistIds);
  }

  
  
  
  
  function _mintCard(
    uint8 _checklistId,
    address _owner
  )
    internal
    returns (uint256)
  {
    uint16 mintLimit = strikersChecklist.limitForChecklistId(_checklistId);
    require(mintLimit == 0 || mintedCountForChecklistId[_checklistId] < mintLimit, "Can't mint any more of this card!");
    uint16 serialNumber = ++mintedCountForChecklistId[_checklistId];
    Card memory newCard = Card({
      mintTime: uint32(now),
      checklistId: _checklistId,
      serialNumber: serialNumber
    });
    uint256 newCardId = cards.push(newCard) - 1;
    emit CardMinted(newCardId);
    _mint(_owner, newCardId);
    return newCardId;
  }
}










