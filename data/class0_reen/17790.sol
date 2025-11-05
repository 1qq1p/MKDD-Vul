pragma solidity ^0.4.19;

contract PChannel is Ownable {
    
    Referral private refProgram;

    
    uint private depositAmount = 25000;

    
    uint private maxDepositAmount = 31250;

    
    mapping (address => uint8) private deposits; 
    
    function PChannel(address _refProgram) public {
        refProgram = Referral(_refProgram);
    }
    
    function() payable public {
        uint8 depositsCount = deposits[msg.sender];
        
        require(depositsCount < 15);

        uint amount = msg.value;
        uint usdAmount = amount * refProgram.ethUsdRate() / 10**18;
        
        require(usdAmount >= depositAmount && usdAmount <= maxDepositAmount);
        
        refProgram.invest.value(amount)(msg.sender, depositsCount);
        deposits[msg.sender]++;
    }

    



    function setRefProgram(address _addr) public onlyOwner {
        refProgram = Referral(_addr);
    }
    
}