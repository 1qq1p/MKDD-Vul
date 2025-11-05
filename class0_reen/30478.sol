pragma solidity ^0.4.18;















contract WeeklyDraw is Owned{
    

    
    bytes32 public number;
    uint public timeLimit;
    uint public ticketsSold;
    
    struct Ticket {
        address addr;
        uint time;
    }
    
    mapping (uint => Ticket) Tickets;

    function start(bytes32 _var1) public {
        if (timeLimit<1){
            timeLimit = now;
            number = _var1 ;
        }
    }

    function () payable{
        uint value = (msg.value)/100000000000000000;
        require (now<(timeLimit+604800));
            uint i = 0;
            while (i++ < value) {
                uint TicketNumber = ticketsSold + i;
                Tickets[TicketNumber].addr = msg.sender;
                Tickets[TicketNumber].time = now;
            } 
            ticketsSold = ticketsSold + value;
   }

    function Play() payable{
        uint value = msg.value/100000000000000000;
        require (now<(timeLimit+604800));
            uint i = 1;
            while (i++ < value) {
                uint TicketNumber = ticketsSold + i;
                Tickets[TicketNumber].addr = msg.sender;
                Tickets[TicketNumber].time = now;
            } 
            ticketsSold = ticketsSold + value;
   }


    function balances() constant returns(uint, uint time){
       return (ticketsSold, (timeLimit+604800)-now);
   }


    function winner(uint _theNumber, bytes32 newNumber) onlyOwner payable {
        require ((timeLimit+604800)<now && number == keccak256(_theNumber));
                
                uint8 add1 = uint8 (Tickets[ticketsSold/4].addr);
                uint8 add2 = uint8 (Tickets[ticketsSold/3].addr);
       
                uint8 time1 = uint8 (Tickets[ticketsSold/2].time);
                uint8 time2 = uint8 (Tickets[ticketsSold/8].time);
       
                uint winningNumber = uint8 (((add1+add2)-(time1+time2))*_theNumber)%ticketsSold;
                
                address winningTicket = address (Tickets[winningNumber].addr);
                
                uint winnings = uint (address(this).balance / 20) * 19;
                uint fees = uint (address(this).balance-winnings)/2;
                uint dividends = uint (address(this).balance-winnings)-fees;
                
                winningTicket.transfer(winnings);
                
                owner.transfer(fees);
                
                dividendsAccount.transfer(dividends);
                
                delete ticketsSold;
                timeLimit = now;
                number = newNumber;

    }

}

