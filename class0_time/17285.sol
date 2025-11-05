pragma solidity ^0.4.19;

contract PonziBaseProcessor is SafeMath, AccessMgr, UserMgr, ItemMgr {
	
	uint256 public mHostFee = 0;
	
	event ItemCreated(address host, uint256 itemId);
	event ItemBought(address buyer, uint256 itemId, uint256 number, uint256 price, uint256 refund);
	
	function PonziBaseProcessor() public {
		mOwner = msg.sender;
	}
	
	function setHostFee(uint256 hostFee) Owner public {
		mHostFee = hostFee;
	}
	
	function createItem(string name, uint256 basePrice, uint256 growthAmount, uint256 growthPeriod) payable public returns (uint256 itemId) {
		address sender = msg.sender;
		User storage user = mUsers[sender];
		uint256 balance = user.balance;
		
		if (msg.value > 0)
			balance = safeAdd(balance, msg.value);
		
		if (basePrice <= 0)
			revert(); 
		
		
		
		
		if (growthPeriod <= 0)
			revert(); 
		
		if (bytes(name).length > 32)
			revert(); 
		
		uint256 fee = basePrice;
		uint256 minFee = mHostFee;
		if (fee < minFee)
			fee = minFee;
		
		if (balance < fee)
			revert(); 
		
		uint256 id = mItems.length;
		mItems.length++;
		
		Item storage item = mItems[id];
		item.name = name;
		item.hostAddress = sender;
		item.price = basePrice;
		item.numSold = 0;
		item.basePrice = basePrice;
		item.growthAmount = growthAmount;
		item.growthPeriod = growthPeriod;
		
		item.purchases.push(mOwner);
		item.purchases.push(sender);
		
		balance = safeSubtract(balance, fee);
		user.balance = balance;
		user.hostedItems.push(id);
		user.inventory.push(id);
		
		User storage owner = mUsers[mOwner];
		owner.balance = safeAdd(owner.balance, fee);
		
		if (mOwner != sender) {
			owner.inventory.push(id);
		}
		
		ItemCreated(sender, id);
		
		return id;
	}
	
	function buyItem(uint256 id) payable public {
		address sender = msg.sender;
		User storage user = mUsers[sender];
		uint256 balance = user.balance;
		
		if (msg.value > 0)
			balance = safeAdd(balance, msg.value);
		
		Item storage item = mItems[id];
		uint256 price = item.price;
		
		if (price == 0)
			revert(); 
		
		if (balance < price)
			revert(); 
		
		balance = safeSubtract(balance, price);
		user.balance = balance;
		user.inventory.push(id);
		
		uint256 length = item.purchases.length;
		
		uint256 refund = price;
		uint256 dividend = price / length;
		for (uint256 i=0; i<length; i++) {
			User storage holder = mUsers[item.purchases[i]];
			holder.balance = safeAdd(holder.balance, dividend);
			refund -= dividend;
		}
		
		
		
		
		item.purchases.push(sender);
		uint256 numSold = item.numSold++;
		
		if (item.numSold % item.growthPeriod == 0)
			item.price = safeAdd(item.price, item.growthAmount);
		
		ItemBought(sender, id, numSold, price, refund);
	}
}