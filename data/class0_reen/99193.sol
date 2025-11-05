pragma solidity >0.4.99 <0.6.0;

contract TicketsStorage is Accessibility, Parameters  {
    using SafeMath for uint;
    using Percent for Percent.percent;

    struct Ticket {
        address payable wallet;
        uint winnerRound;
    }

    struct CountWinner {
        uint countWinnerRound_1;
        uint countWinnerRound_2;
        uint countWinnerRound_3;
        uint countWinnerRound_4;
        uint countWinnerRound_5;
    }

    struct PayEachWinner {
        uint payEachWinner_1;
        uint payEachWinner_2;
        uint payEachWinner_3;
        uint payEachWinner_4;
        uint payEachWinner_5;
    }

    uint private stepEntropy = 1;
    uint private precisionPay = 4;

    uint private remainStepTS;
    uint private countStepTS;

    mapping (uint => CountWinner) countWinner;
    

    mapping (uint => PayEachWinner) payEachWinner;
    

    mapping (uint => uint) private countTickets;
    

    mapping (uint => mapping (uint => Ticket)) private tickets;
    

    mapping (uint => mapping (address => uint)) private balancePlayer;
    

    mapping (uint => mapping (address => uint)) private balanceWinner;
    

    mapping (uint => uint[]) private happyTickets;
    

    Percent.percent private percentTicketPrize_2 = Percent.percent(1,100);            
    Percent.percent private percentTicketPrize_3 = Percent.percent(4,100);            
    Percent.percent private percentTicketPrize_4 = Percent.percent(10,100);            
    Percent.percent private percentTicketPrize_5 = Percent.percent(35,100);            

    Percent.percent private percentAmountPrize_1 = Percent.percent(1797,10000);            
    Percent.percent private percentAmountPrize_2 = Percent.percent(1000,10000);            
    Percent.percent private percentAmountPrize_3 = Percent.percent(1201,10000);            
    Percent.percent private percentAmountPrize_4 = Percent.percent(2000,10000);            
    Percent.percent private percentAmountPrize_5 = Percent.percent(3502,10000);            


    event LogMakeDistribution(uint roundLottery, uint roundDistibution, uint countWinnerRound, uint payEachWinner);
    event LogHappyTicket(uint roundLottery, uint roundDistibution, uint happyTicket);

    function isWinner(uint round, uint numberTicket) public view returns (bool) {
        return tickets[round][numberTicket].winnerRound > 0;
    }

    function getBalancePlayer(uint round, address wallet) public view returns (uint) {
        return balancePlayer[round][wallet];
    }

    function getBalanceWinner(uint round, address wallet) public view returns (uint) {
        return balanceWinner[round][wallet];
    }

    function ticketInfo(uint round, uint numberTicket) public view returns(address payable wallet, uint winnerRound) {
        Ticket memory ticket = tickets[round][numberTicket];
        wallet = ticket.wallet;
        winnerRound = ticket.winnerRound;
    }

    function newTicket(uint round, address payable wallet, uint priceOfToken) public onlyOwner {
        countTickets[round]++;
        Ticket storage ticket = tickets[round][countTickets[round]];
        ticket.wallet = wallet;
        balancePlayer[round][wallet] = balancePlayer[round][wallet].add(priceOfToken);
    }

    function clearRound(uint round) public {
        countTickets[round] = 0;
        countWinner[round] = CountWinner(0,0,0,0,0);
        payEachWinner[round] = PayEachWinner(0,0,0,0,0);
        stepEntropy = 1;
        remainStepTS = 0;
        countStepTS = 0;
    }

    function makeDistribution(uint round, uint priceOfToken) public onlyOwner {
        uint count = countTickets[round];
        uint amountEthCurrentRound = count.mul(priceOfToken);

        makeCountWinnerRound(round, count);
        makePayEachWinner(round, amountEthCurrentRound);

        CountWinner memory cw = countWinner[round];
        PayEachWinner memory pw = payEachWinner[round];

        emit LogMakeDistribution(round, 1, cw.countWinnerRound_1, pw.payEachWinner_1);
        emit LogMakeDistribution(round, 2, cw.countWinnerRound_2, pw.payEachWinner_2);
        emit LogMakeDistribution(round, 3, cw.countWinnerRound_3, pw.payEachWinner_3);
        emit LogMakeDistribution(round, 4, cw.countWinnerRound_4, pw.payEachWinner_4);
        emit LogMakeDistribution(round, 5, cw.countWinnerRound_5, pw.payEachWinner_5);

        if (happyTickets[round].length > 0) {
            delete happyTickets[round];
        }
    }

    function makeCountWinnerRound(uint round, uint cntTickets) internal {
        uint cw_1 = 1;
        uint cw_2 = percentTicketPrize_2.mmul(cntTickets);
        uint cw_3 = percentTicketPrize_3.mmul(cntTickets);
        uint cw_4 = percentTicketPrize_4.mmul(cntTickets);
        uint cw_5 = percentTicketPrize_5.mmul(cntTickets);

        countWinner[round] = CountWinner(cw_1, cw_2, cw_3, cw_4, cw_5);
    }

    function makePayEachWinner(uint round, uint amountEth) internal {
        CountWinner memory cw = countWinner[round];

        uint pw_1 = roundEth(percentAmountPrize_1.mmul(amountEth).div(cw.countWinnerRound_1), precisionPay);
        uint pw_2 = roundEth(percentAmountPrize_2.mmul(amountEth).div(cw.countWinnerRound_2), precisionPay);
        uint pw_3 = roundEth(percentAmountPrize_3.mmul(amountEth).div(cw.countWinnerRound_3), precisionPay);
        uint pw_4 = roundEth(percentAmountPrize_4.mmul(amountEth).div(cw.countWinnerRound_4), precisionPay);
        uint pw_5 = roundEth(percentAmountPrize_5.mmul(amountEth).div(cw.countWinnerRound_5), precisionPay);

        payEachWinner[round] = PayEachWinner(pw_1, pw_2, pw_3, pw_4, pw_5);

    }

    function getCountTickets(uint round) public view returns (uint) {
        return countTickets[round];
    }

    function getCountTwist(uint countsTickets, uint maxCountTicketByStep) public returns(uint countTwist) {
        countTwist = countsTickets.div(2).div(maxCountTicketByStep);
        if (countsTickets > countTwist.mul(2).mul(maxCountTicketByStep)) {
            remainStepTS = countsTickets.sub(countTwist.mul(2).mul(maxCountTicketByStep));
            countTwist++;
        }
        countStepTS = countTwist;

    }

    function getMemberArrayHappyTickets(uint round, uint index) public view returns (uint value) {
        value =  happyTickets[round][index];
    }

    function getLengthArrayHappyTickets(uint round) public view returns (uint length) {
        length = happyTickets[round].length;
    }

    function getStepTransfer() public view returns (uint stepTransfer, uint remainTicket) {
        stepTransfer = countStepTS;
        remainTicket = remainStepTS;
    }

    function getCountWinnersDistrib(uint round) public view returns (uint countWinnerRound_1, uint countWinnerRound_2, uint countWinnerRound_3, uint countWinnerRound_4, uint countWinnerRound_5) {
        CountWinner memory cw = countWinner[round];

        countWinnerRound_1 = cw.countWinnerRound_1;
        countWinnerRound_2 = cw.countWinnerRound_2;
        countWinnerRound_3 = cw.countWinnerRound_3;
        countWinnerRound_4 = cw.countWinnerRound_4;
        countWinnerRound_5 = cw.countWinnerRound_5;
    }

    function getPayEachWinnersDistrib(uint round) public view returns (uint payEachWinner_1, uint payEachWinner_2, uint payEachWinner_3, uint payEachWinner_4, uint payEachWinner_5) {
        PayEachWinner memory pw = payEachWinner[round];

        payEachWinner_1 = pw.payEachWinner_1;
        payEachWinner_2 = pw.payEachWinner_2;
        payEachWinner_3 = pw.payEachWinner_3;
        payEachWinner_4 = pw.payEachWinner_4;
        payEachWinner_5 = pw.payEachWinner_5;
    }

    function addBalanceWinner(uint round, uint amountPrize, uint happyNumber) public onlyOwner {
        balanceWinner[round][tickets[round][happyNumber].wallet] = balanceWinner[round][tickets[round][happyNumber].wallet].add(amountPrize);
    }

    function setWinnerRountForTicket(uint round, uint winnerRound, uint happyNumber) public onlyOwner {
        tickets[round][happyNumber].winnerRound = winnerRound;
    }

    

    function addHappyNumber(uint round, uint numCurTwist, uint happyNumber) public onlyOwner {
        happyTickets[round].push(happyNumber);
        emit LogHappyTicket(round, numCurTwist, happyNumber);
    }

    function findHappyNumber(uint round) public onlyOwner returns(uint) {
        stepEntropy++;
        uint happyNumber = getRandomNumberTicket(stepEntropy, round);
        while (tickets[round][happyNumber].winnerRound > 0) {
            stepEntropy++;
            happyNumber++;
            if (happyNumber > countTickets[round]) {
                happyNumber = 1;
            }
        }
        return happyNumber;
    }

    function getRandomNumberTicket(uint entropy, uint round) public view returns(uint) {
        require(countTickets[round] > 0, "number of tickets must be greater than 0");
        uint randomFirst = maxRandom(block.number, msg.sender).div(now);
        uint randomNumber = randomFirst.mul(entropy) % (countTickets[round]);
        if (randomNumber == 0) { randomNumber = 1;}
        return randomNumber;
    }

    function random(uint upper, uint blockn, address entropy) internal view returns (uint randomNumber) {
        return maxRandom(blockn, entropy) % upper;
    }

    function maxRandom(uint blockn, address entropy) internal view returns (uint randomNumber) {
        return uint(keccak256(
                abi.encodePacked(
                    blockhash(blockn),
                    entropy)
            ));
    }

    function roundEth(uint numerator, uint precision) internal pure returns(uint round) {
        if (precision > 0 && precision < 18) {
            uint256 _numerator = numerator / 10 ** (18 - precision - 1);
            
            _numerator = (_numerator) / 10;
            round = (_numerator) * 10 ** (18 - precision);
        }
    }


}
