pragma solidity ^0.4.18;





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
    
    uint256 c = a / b;
    
    return c;
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






contract IcoContract is IcoPhase, Ownable, Pausable, Affiliate, Bonus {
	using SafeMath for uint256;

	JWCToken ccc;

	uint256 public totalTokenSale;
	uint256 public minContribution = 0.5 ether;
	uint256 public tokenExchangeRate = 7000;
	uint256 public constant decimals = 18;

	uint256 public tokenRemainPreSale;
	uint256 public tokenRemainPublicSale;

	address public ethFundDeposit = 0xC69f762Cf7255c13e616E8D8eb328A6588cA2826;
	address public tokenAddress;

	bool public isFinalized;

	uint256 public maxGasRefund = 0.004 ether;

	
	function IcoContract(address _tokenAddress) public {
		tokenAddress = _tokenAddress;

		ccc = JWCToken(tokenAddress);
		totalTokenSale = ccc.tokenPreSale() + ccc.tokenPublicSale();

		tokenRemainPreSale = ccc.tokenPreSale();
		tokenRemainPublicSale = ccc.tokenPublicSale();

		isFinalized=false;
	}

	



	function changeETH2Token(uint256 _value) public constant returns(uint256) {
		uint256 etherRecev = _value + maxGasRefund;
		require (etherRecev >= minContribution);

		uint256 rate = getTokenExchangeRate();

		uint256 tokens = etherRecev.mul(rate);

		
		uint256 phaseICO = getCurrentICOPhase();
		uint256 tokenRemain = 0;
		if(phaseICO == 1){
			tokenRemain = tokenRemainPreSale;
		} else if (phaseICO == 2 || phaseICO == 3 || phaseICO == 4) {
			tokenRemain = tokenRemainPublicSale;
		}

		if (tokenRemain < tokens) {
			tokens=tokenRemain;
		}

		return tokens;
	}

	


	function () public payable whenNotPaused {
		require (!isFinalized);
		require (msg.sender != address(0));

		uint256 etherRecev = msg.value + maxGasRefund;
		require (etherRecev >= minContribution);

		
		tokenExchangeRate = getTokenExchangeRate();

		uint256 tokens = etherRecev.mul(tokenExchangeRate);

		
		uint256 phaseICO = getCurrentICOPhase();

		require(phaseICO!=0);

		uint256 tokenRemain = 0;
		if(phaseICO == 1){
			tokenRemain = tokenRemainPreSale;
		} else if (phaseICO == 2 || phaseICO == 3 || phaseICO == 4) {
			tokenRemain = tokenRemainPublicSale;
		}

		
		require(tokenRemain>0);

		if (tokenRemain < tokens) {
			

			uint256 tokensToRefund = tokens.sub(tokenRemain);
			uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

			
			msg.sender.transfer(etherToRefund);

			tokens=tokenRemain;
			etherRecev = etherRecev.sub(etherToRefund);

			tokenRemain = 0;
		} else {
			tokenRemain = tokenRemain.sub(tokens);
		}

		
		if(phaseICO == 1){
			tokenRemainPreSale = tokenRemain;
		} else if (phaseICO == 2 || phaseICO == 3 || phaseICO == 4) {
			tokenRemainPublicSale = tokenRemain;
		}

		
		ccc.sell(msg.sender, tokens);
		ethFundDeposit.transfer(this.balance);

		
		if(isBonus){
			
			uint256 bonusTimeToken = tokens.mul(getTimeBonus())/100;

			
			if(bonusAccountBalances[msg.sender]==0){
				bonusAccountIndex[bonusAccountCount]=msg.sender;
				bonusAccountCount++;
			}

			bonusAccountBalances[msg.sender]=bonusAccountBalances[msg.sender].add(bonusTimeToken);
		}

		
		if(isAffiliate){
			address child=msg.sender;
			for(uint256 i=0; i<affiliateLevel; i++){
				uint256 giftToken=affiliateRate[i].mul(tokens)/100;

				address parent = referral[child];
				if(parent != address(0x00)){
					referralBalance[child]=referralBalance[child].add(giftToken);
				}

				child=parent;
			}
		}
	}

	


	function payAffiliate() public onlyOwner returns (bool success) {
		uint256 toIndex = indexPaidAffiliate + 15;
		if(referralCount < toIndex)
			toIndex = referralCount;

		for(uint256 i=indexPaidAffiliate; i<toIndex; i++) {
			address referee = referralIndex[i];

			if(referralBalance[referee]>0)
				payAffiliate1Address(referee);
		}

		return true;
	}

	



	function payAffiliate1Address(address _referee) public onlyOwner returns (bool success) {
		address referrer = referral[_referee];
		ccc.payBonusAffiliate(referrer, referralBalance[_referee]);

		referralBalance[_referee]=0;
		return true;
	}

	


	function payBonus() public onlyOwner returns (bool success) {
		uint256 toIndex = indexPaidBonus + 15;
		if(bonusAccountCount < toIndex)
			toIndex = bonusAccountCount;

		for(uint256 i=indexPaidBonus; i<toIndex; i++)
		{
			if(bonusAccountBalances[bonusAccountIndex[i]]>0)
				payBonus1Address(bonusAccountIndex[i]);
		}

		return true;
	}

	



	function payBonus1Address(address _address) public onlyOwner returns (bool success) {
		ccc.payBonusAffiliate(_address, bonusAccountBalances[_address]);
		bonusAccountBalances[_address]=0;
		return true;
	}

	function finalize() external onlyOwner {
		require (!isFinalized);
		
		isFinalized = true;
		payAffiliate();
		payBonus();
		ethFundDeposit.transfer(this.balance);
	}

	


	function getTokenExchangeRate() public constant returns(uint256 rate) {
		rate = tokenExchangeRate;
		if(now<phasePresale_To){
			if(now>=phasePresale_From)
				rate = 10000;
		} else if(now<phasePublicSale3_To){
			rate = 7000;
		}
	}

	


	function getCurrentICOPhase() public constant returns(uint256 phase) {
		phase = 0;
		if(now>=phasePresale_From && now<phasePresale_To){
			phase = 1;
		} else if (now>=phasePublicSale1_From && now<phasePublicSale1_To) {
			phase = 2;
		} else if (now>=phasePublicSale2_From && now<phasePublicSale2_To) {
			phase = 3;
		} else if (now>=phasePublicSale3_From && now<phasePublicSale3_To) {
			phase = 4;
		}
	}

	


	function getTokenSold() public constant returns(uint256 tokenSold) {
		
		uint256 phaseICO = getCurrentICOPhase();
		tokenSold = 0;
		if(phaseICO == 1){
			tokenSold = ccc.tokenPreSale().sub(tokenRemainPreSale);
		} else if (phaseICO == 2 || phaseICO == 3 || phaseICO == 4) {
			tokenSold = ccc.tokenPreSale().sub(tokenRemainPreSale) + ccc.tokenPublicSale().sub(tokenRemainPublicSale);
		}
	}

	



	function setTokenExchangeRate(uint256 _tokenExchangeRate) public onlyOwner returns (bool) {
		require(_tokenExchangeRate>0);
		tokenExchangeRate=_tokenExchangeRate;
		return true;
	}

	



	function setMinContribution(uint256 _minContribution) public onlyOwner returns (bool) {
		require(_minContribution>0);
		minContribution=_minContribution;
		return true;
	}

	



	function setEthFundDeposit(address _ethFundDeposit) public onlyOwner returns (bool) {
		require(_ethFundDeposit != address(0));
		ethFundDeposit=_ethFundDeposit;
		return true;
	}

	



	function setMaxGasRefund(uint256 _maxGasRefund) public onlyOwner returns (bool) {
		require(_maxGasRefund > 0);
		maxGasRefund = _maxGasRefund;
		return true;
	}
}