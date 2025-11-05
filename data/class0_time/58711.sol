pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract SurveyToken is TokenERC20, owned
{
    struct Survey {
        address initiator;
        uint256 toPay;
        uint256 balance;
        uint32 tickets;
        uint256 reward;
        mapping(address => bool) respondents;
    }

    address feeReceiver;

    mapping(bytes32 => Survey) surveys;
    mapping(address => bool) robots;

    modifier onlyRobot {
        require(robots[msg.sender]);
        _;
    }

    function SurveyToken(uint256 initialSupply) public
    TokenERC20(initialSupply) {
        feeReceiver = msg.sender;
    }

    function setFeeReceiver(address newReceiver) public onlyOwner {
        require(newReceiver != 0x0);
        feeReceiver = newReceiver;
    }

    function addRobot(address newRobot) public onlyOwner returns(bool success) {
        require(newRobot != 0x0);
        require(robots[newRobot] == false);

        robots[newRobot] = true;
        return true;
    }
    function removeRobot(address oldRobot) public onlyOwner returns(bool success) {
        require(oldRobot != 0x0);
        require(robots[oldRobot] == true);

        robots[oldRobot] = false;
        return true;
    }

    function placeNewSurvey(bytes32 key, uint256 toPay, uint32 tickets, uint256 reward) public returns(bool success) {
        require(surveys[key].initiator == 0x0);
        require(tickets > 0 && reward >= 0);
        uint256 rewardBalance = tickets * reward;
        require(rewardBalance < toPay && toPay > 0);
        require(balanceOf[msg.sender] >= toPay);
        
        uint256 fee = toPay - rewardBalance;
        require(balanceOf[feeReceiver] + fee > balanceOf[feeReceiver]);
        transfer(feeReceiver, fee);
        
        balanceOf[msg.sender] -= rewardBalance;
        surveys[key] = Survey(msg.sender, toPay, rewardBalance, tickets, reward);
        Transfer(msg.sender, 0x0, rewardBalance);
        return true;
    }

    function giveReward(bytes32 surveyKey, address respondent, uint8 karma) public onlyRobot returns(bool success) {
        require(respondent != 0x0);
        Survey storage surv = surveys[surveyKey];
        require(surv.respondents[respondent] == false);
        require(surv.tickets > 0 && surv.reward > 0 && surv.balance >= surv.reward);
        require(karma >= 0 && karma <= 10);
        
        if (karma < 10) {
            uint256 fhalf = surv.reward / 2;
            uint256 shalf = ((surv.reward - fhalf) / 10) * karma;
            uint256 respReward = fhalf + shalf;
            uint256 fine = surv.reward - respReward;
            
            require(balanceOf[respondent] + respReward > balanceOf[respondent]);
            require(balanceOf[feeReceiver] + fine > balanceOf[feeReceiver]);
            
            balanceOf[respondent] += respReward;
            Transfer(0x0, respondent, respReward);
            
            balanceOf[feeReceiver] += fine;
            Transfer(0x0, feeReceiver, fine);
        } else {
            require(balanceOf[respondent] + surv.reward > balanceOf[respondent]);
            balanceOf[respondent] += surv.reward;
            Transfer(0x0, respondent, surv.reward);
        }

        surv.tickets--;
        surv.balance -= surv.reward;
        surv.respondents[respondent] = true;
        return true;
    }
    
    function removeSurvey(bytes32 surveyKey) public onlyRobot returns(bool success) {
        Survey storage surv = surveys[surveyKey];
        require(surv.initiator != 0x0 && surv.balance > 0);
        require(balanceOf[surv.initiator] + surv.balance > balanceOf[surv.initiator]);
        
        balanceOf[surv.initiator] += surv.balance;
        Transfer(0x0, surv.initiator, surv.balance);
        surv.balance = 0;
        return true;
    }

    function getSurveyInfo(bytes32 key) public constant returns(bool success, uint256 toPay, uint32 tickets, uint256 reward) {
        Survey storage surv = surveys[key];
        require(surv.initiator != 0x0);

        return (true, surv.toPay, surv.tickets, surv.reward);
    }
}