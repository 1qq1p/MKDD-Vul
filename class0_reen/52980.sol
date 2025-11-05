pragma solidity ^0.4.21;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract PepeCore is PullPayment, OwnerRegistry, SaleRegistry, ArtistRegistry {
  using SafeMath for uint256;

  uint256 constant public totalTxFeePercent = 4;

  
  
  

  
  
  address public shareholder1;
  address public shareholder2;
  address public shareholder3;

  
  uint256 public numShareholders = 0;

  
  function addShareholderAddress(address newShareholder) external onlyOwner {
    
    require(newShareholder != address(0));

    
    require(newShareholder != owner);

    
    require(shareholder1 == address(0) || shareholder2 == address(0) || shareholder3 == address(0));

    if (shareholder1 == address(0)) {
      shareholder1 = newShareholder;
      numShareholders = numShareholders.add(1);
    } else if (shareholder2 == address(0)) {
      shareholder2 = newShareholder;
      numShareholders = numShareholders.add(1);
    } else if (shareholder3 == address(0)) {
      shareholder3 = newShareholder;
      numShareholders = numShareholders.add(1);
    }
  }

  
  function payShareholders(uint256 amount) internal {
    
    if (numShareholders > 0) {
      uint256 perShareholderFee = amount.div(numShareholders);

      if (shareholder1 != address(0)) {
        asyncSend(shareholder1, perShareholderFee);
      }

      if (shareholder2 != address(0)) {
        asyncSend(shareholder2, perShareholderFee);
      }

      if (shareholder3 != address(0)) {
        asyncSend(shareholder3, perShareholderFee);
      }
    }
  }

  
  
  

  function withdrawContractBalance() external onlyOwner {
    uint256 contractBalance = address(this).balance;
    uint256 withdrawableBalance = contractBalance.sub(totalPayments);

    
    require(withdrawableBalance > 0);

    msg.sender.transfer(withdrawableBalance);
  }

  function addCard(bytes32 sig,
                   address artist,
                   uint256 txFeePercent,
                   uint256 genesisSalePercent,
                   uint256 numToAdd,
                   uint256 startingPrice) external onlyOwner {
    addCardToRegistry(owner, sig, numToAdd);

    addArtistToRegistry(sig, artist, txFeePercent, genesisSalePercent);

    postGenesisSales(sig, startingPrice, numToAdd);
  }

  
  
  

  function createSale(bytes32 sig, uint256 price) external {
    
    require(price > 0);

    
    require(getNumSigsOwned(sig) > 0);

    
    require(msg.sender == owner || _addressToSigToSalePrice[msg.sender][sig] == 0);

    postSale(msg.sender, sig, price);
  }

  function removeSale(bytes32 sig) public {
    
    require(_addressToSigToSalePrice[msg.sender][sig] > 0);

    cancelSale(msg.sender, sig);
  }

  function computeTxFee(uint256 price) private pure returns (uint256) {
    return (price * totalTxFeePercent) / 100;
  }

  
  function paySellerFee(bytes32 sig, address seller, uint256 sellerProfit) private {
    if (seller == owner) {
      address artist = getArtist(sig);
      uint256 artistFee = computeArtistGenesisSaleFee(sig, sellerProfit);
      asyncSend(artist, artistFee);

      payShareholders(sellerProfit.sub(artistFee));
    } else {
      asyncSend(seller, sellerProfit);
    }
  }

  
  function payTxFees(bytes32 sig, uint256 txFee) private {
    uint256 artistFee = computeArtistTxFee(sig, txFee);
    address artist = getArtist(sig);
    asyncSend(artist, artistFee);

    payShareholders(txFee.sub(artistFee));
  }

  
  function buy(bytes32 sig) external payable {
    address seller;
    uint256 price;
    (seller, price) = getBestSale(sig);

    
    require(price > 0 && seller != address(0));

    
    uint256 availableEth = msg.value.add(payments[msg.sender]);
    require(availableEth >= price);

    
    if (msg.value < price) {
      asyncDebit(msg.sender, price.sub(msg.value));
    }

    
    uint256 txFee = computeTxFee(price);
    uint256 sellerProfit = price.sub(txFee);

    
    paySellerFee(sig, seller, sellerProfit);

    
    payTxFees(sig, txFee);

    
    cancelSale(seller, sig);

    
    registryTransfer(seller, msg.sender, sig, 1);
  }

  
  function transferSig(bytes32 sig, uint256 count, address newOwner) external {
    uint256 numOwned = getNumSigsOwned(sig);

    
    require(numOwned >= count);

    
    if (msg.sender == owner) {
      uint256 remaining = numOwned.sub(count);

      if (remaining < _ownerSigToNumSales[sig]) {
        uint256 numSalesToCancel = _ownerSigToNumSales[sig].sub(remaining);

        for (uint256 i = 0; i < numSalesToCancel; i++) {
          removeSale(sig);
        }
      }
    } else {
      
      if (numOwned == count && _addressToSigToSalePrice[msg.sender][sig] > 0) {
        removeSale(sig);
      }
    }

    
    registryTransfer(msg.sender, newOwner, sig, count);
  }
}