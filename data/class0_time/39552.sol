pragma solidity ^0.4.6;

contract CampaignBeneficiary is Campaign, RES, SwarmRedistribution {

    event BuyWithPathwayFromBeneficiary(address from, uint amount);

    function CampaignBeneficiary() {
      isHuman[JohanNygren] = true;
    }

    function simulatePathwayFromBeneficiary() isOpen public payable {
      balanceOf[msg.sender] += msg.value;
      totalSupply += msg.value;  

      
      dividendPathways[msg.sender].push(dividendPathway({
                                      from: JohanNygren, 
                                      amount:  msg.value,
                                      timeStamp: now
                                    }));

      BuyWithPathwayFromBeneficiary(msg.sender, msg.value);
    }

}