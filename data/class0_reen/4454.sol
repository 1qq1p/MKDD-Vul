pragma solidity 0.4.25;

library SafeMath {
	function mul (uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div (uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}

	function sub (uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add (uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract FountainTokenUpgrade is FountainToken {
	event UpgradeStart();
	event UpgradeStop();
	event SetRefund(address, uint);
	event Refund(address, uint);
	event SetFoundation(uint);
	event FinishUpgrade();
	
	bool public upgrade_running;

	bool public upgrade_finish;
	
	FountainToken ftn;
	
	address public oldContract;
	
	mapping(address=>bool) public upgraded;
	mapping(address=>bool) public skiplist;

	mapping(address=>uint) public refundlist;


	constructor(address old){
		oldContract = old;
		ftn = FountainToken(old);
	}

	modifier canUpgrade(){
		require(!upgrade_finish);
		_;
	}

	modifier whenUpgrading() {
		require(upgrade_running);
		_;
	}

	modifier whenNotUpgrading() {
		require(!upgrade_running);
		_;
	}

	function finishUpgrade() public whenNotUpgrading canUpgrade onlyOwner{
		upgrade_finish = true;
		emit FinishUpgrade();
	}

	function setFoundation(uint amount) public whenUpgrading whenPaused canUpgrade onlyOwner {
		token_foundation_created = amount;
		emit SetFoundation(amount);
	}

	function setRefund(address addr, uint amount) public whenUpgrading canUpgrade onlyOwner {
		require(addr != address(0));
		require(addr != foundationOwner);
		require(addr != owner);
		refundlist[addr] = amount;
		emit SetRefund(addr, amount);
	}

	function batchSetRefund(address[] addrs, uint[] amounts) public whenUpgrading canUpgrade onlyOwner {
		uint l1 = addrs.length;
		uint l2 = amounts.length;
		address addr;
		uint amount;
		require(l1 > 0 && l1 == l2);
		for (uint i = 0; i < l1; i++){
			addr = addrs[i];
			amount = amounts[i];
			if (addr == address(0) || addr == foundationOwner || addr == owner) continue;
			refundlist[addr] = amount;
			emit SetRefund(addr, amount);
		}
	}


	function runRefund(address addr) public whenUpgrading canUpgrade onlyOwner {
		uint amount = refundlist[addr];
		wallets[addr] = wallets[addr].add(amount); 
		token_created = token_created.add(amount);
		refundlist[addr] = 0;
		emit Refund(addr, amount);
		emit Mint(addr, amount);
		emit Transfer(address(0), addr, amount);
	}

	function batchRunRefund(address[] addrs) public whenUpgrading canUpgrade onlyOwner {
		uint l = addrs.length;
		address addr;
		uint amount;
		require(l > 0);
		for (uint i = 0; i < l; i++){
			addr = addrs[i];
			amount = refundlist[addr];
			wallets[addr] = wallets[addr].add(amount); 
			token_created = token_created.add(amount);
			refundlist[addr] = 0;
			emit Refund(addr, amount);
			emit Mint(addr, amount);
			emit Transfer(address(0), addr, amount);
		}
	}

	function startUpgrade() public whenNotUpgrading canUpgrade onlyOwner {
		upgrade_running = true;
		emit UpgradeStart();
	}

	function stopUpgrade() public whenUpgrading canUpgrade onlyOwner {
		upgrade_running = false;
		emit UpgradeStop();
	}

	function setSkiplist(address[] addrs) public whenUpgrading whenPaused canUpgrade onlyOwner {
		uint len = addrs.length;
		if (len>0){
			for (uint i = 0; i < len; i++){
				skiplist[addrs[i]] = true;
			}
		}
	}

	function upgrade(address addr) whenUpgrading whenPaused canUpgrade onlyOwner{
		uint amount = ftn.balanceOf(addr);
		require(!upgraded[addr] && amount>0 && !skiplist[addr]);

		upgraded[addr] = true;
		wallets[addr] = amount;

		(uint a, uint b, uint c, uint d) = ftn.lockbins(addr,0);
		uint len = d;
		if (len > 0){
			lockbins[addr][0].amount = len; 
			for (uint i=1; i <= len; i++){
				(a, b, c, d) = ftn.lockbins(addr,i);
				lockbins[addr][i] = LockBin({
					start: a,
					finish: b,
					duration: c,
					amount: d
				});
			}
		}

		token_created = token_created.add(amount);
		emit Mint(addr, amount);
		emit Transfer(address(0), addr, amount);
	}
	
	
	function batchUpgrade(address[] addrs) whenUpgrading whenPaused canUpgrade onlyOwner{
		uint l = addrs.length;
		require(l > 0);
		uint a;
		uint b; 
		uint c; 
		uint d;
		for (uint i = 0; i < l; i++){

			address addr = addrs[i];
			uint amount = ftn.balanceOf(addr);
			if (upgraded[addr] || amount == 0 || skiplist[addr]){
				continue;
			}

			upgraded[addr] = true;
			wallets[addr] = amount;
	
			(a, b, c, d) = ftn.lockbins(addr,0);
			uint len = d;
			if (len > 0){
				lockbins[addr][0].amount = len; 
				for (uint j=1; j <= len; j++){
					(a, b, c, d) = ftn.lockbins(addr, j);
					lockbins[addr][j] = LockBin({
						start: a,
						finish: b,
						duration: c,
						amount: d
					});
				}
			}

			token_created = token_created.add(amount);
			emit Mint(addr, amount);
			emit Transfer(address(0), addr, amount);

		} 
		
	}

}