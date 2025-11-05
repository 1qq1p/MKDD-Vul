




pragma solidity ^0.4.18;

contract Giveaway is BinksBucksToken {
    




    address internal giveaway_master;
    address internal imperator;
    uint32 internal _code = 0;
    uint internal _distribution_size = 1000000000000000000000;
    uint internal _max_distributions = 100;
    uint internal _distributions_left = 100;
    uint internal _distribution_number = 0;
    mapping(address => uint256) internal _last_distribution;

    function transferAdmin(address newImperator) public {
            require(msg.sender == imperator);
            imperator = newImperator;
        }

    function transferGiveaway(address newaddress) public {
        require(msg.sender == imperator || msg.sender == giveaway_master);
        giveaway_master = newaddress;
    }

    function startGiveaway(uint32 code, uint max_distributions) public {
        



        require(msg.sender == imperator || msg.sender == giveaway_master);
        _code = code;
        _max_distributions = max_distributions;
        _distributions_left = max_distributions;
        _distribution_number += 1;
    }

    function setDistributionSize(uint num) public {
        




        require(msg.sender == imperator || msg.sender == giveaway_master);
        _code = 0;
        _distribution_size = num;
    }

    function CodeEligible() public view returns (bool) {
        


        return (_code != 0 && _distributions_left > 0 && _distribution_number > _last_distribution[msg.sender]);
    }

    function EnterCode(uint32 code) public {
        


        require(CodeEligible());
        if (code == _code) {
            _last_distribution[msg.sender] = _distribution_number;
            _distributions_left -= 1;
            require(canRecieve(msg.sender, _distribution_size));
            require(hasAtLeast(this, _distribution_size));
            _balances[this] -= _distribution_size;
            _balances[msg.sender] += _distribution_size;
            Transfer(this, msg.sender, _distribution_size);
        }
    }
}
