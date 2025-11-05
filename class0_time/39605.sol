pragma solidity 0.4.18;

contract Bonuses {
    using SafeMath for uint256;

    DLCToken public token;

    uint256 public startTime;
    uint256 public endTime;

    mapping(uint => uint256) public bonusOfDay;

    bool public bonusInited = false;

    function initBonuses (string _preset) public {
        require(!bonusInited);
        bonusInited = true;
        bytes32 preset = keccak256(_preset);

        if(preset == keccak256('privatesale')){
            bonusOfDay[0] = 313;
        } else
        if(preset == keccak256('presale')){
            bonusOfDay[0] = 210;
        } else
        if(preset == keccak256('generalsale')){
            bonusOfDay[0] = 60;
            bonusOfDay[7] = 38;
            bonusOfDay[14] = 10;
        }
    }

    function calculateTokensQtyByEther(uint256 amount) public constant returns(uint256) {
        int dayOfStart = int(now.sub(startTime).div(86400).add(1));
        uint currentBonus = 0;
        int i;

        for (i = dayOfStart; i >= 0; i--) {
            if (bonusOfDay[uint(i)] > 0) {
                currentBonus = bonusOfDay[uint(i)];
                break;
            }
        }

        return amount.div(token.priceOfToken()).mul(currentBonus + 100).div(100).mul(1 ether);
    }
}
