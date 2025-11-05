pragma solidity 0.4.18;








contract Configurator is Ownable {

 FABAToken public token;

  Presale public presale;

  Mainsale public mainsale;

  function deploy() public onlyOwner {
    
   
   

    token = new FABAToken();

    presale = new Presale();

    presale.setWallet(0x66CeD6f10d77ae5F8dd7811824EF71ebC0c8aEFf);
    presale.setStart(1519862400);
    presale.setPeriod(300);
    presale.setPrice(600000000000000000000);
    presale.setHardcap(500000000000000000000);
    token.setSaleAgent(presale);
    commonConfigure(presale, token);

    mainsale = new Mainsale();

    mainsale.addMilestone(30,20);
    mainsale.addMilestone(30,15);
    mainsale.addMilestone(30,10);
	
  
      
    mainsale.setPrice(450000000000000000000);
    mainsale.setWallet(0x66CeD6f10d77ae5F8dd7811824EF71ebC0c8aEFf);
    mainsale.setFABAcompanyTokensWallet(0x96E187bdD7d817275aD45688BF85CD966A80A428);
    mainsale.setTymTokensWallet(0x781b6EeCa4119f7B9633a03001616161c698b2c5);
    mainsale.setStart(1551398400);
    mainsale.setHardcap(112500000000000000000000);
   
    
    mainsale.setFABAcompanyTokensPercent(40);
    mainsale.setTymTokensPercent(8);
   
    commonConfigure(mainsale, token);
	
    presale.setMainsale(mainsale);

    token.transferOwnership(owner);
    presale.transferOwnership(owner);
    mainsale.transferOwnership(owner);
  }

  function commonConfigure(address saleAddress, address _token) internal {
     FABACommonSale  sale = FABACommonSale (saleAddress);
     sale.addValueBonus(1000000000000000000,0);
     sale.setReferalsMinInvestLimit(500000000000000000);
     sale.setRefererPercent(15);
     sale.setMinInvestedLimit(300000000000000000);
     sale.setToken(_token);
  }

}


