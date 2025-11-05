pragma solidity ^0.4.17;

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

contract PixelToken is StandardToken, BurnableToken, Ownable {
    using SafeMath for uint;

    string constant public symbol = "PXLT";
    string constant public name = "Pixel Crowdsale Token";

    uint8 constant public decimals = 18;
    uint256 INITIAL_SUPPLY = 20000000e18;

    uint constant ITSStartTime = 1523350800; 
    uint constant ITSEndTime = 1526446800; 
    uint constant unlockTime = 1546300800; 

    address company = 0x5028aea7b621782ca58fe066b5b16b4fe2ead8d6;
    address team = 0x628f126d16acf0ba234f5ece4aa5bc2baba7ffda;

    address crowdsale = 0x7085a139792aec99514352a3cfa657cdd4aeabbc;
    address bounty = 0x214c50f0133943f06060ee693353d91ef2c693c7;

    address beneficiary = 0x143f85a5e90ed6a1409536a723589203b59bbe7e;

    uint constant companyTokens = 2400000e18;
    uint constant teamTokens = 1800000e18;
    uint constant crowdsaleTokens = 15000000e18;
    uint constant bountyTokens = 800000e18;

    function PixelToken() public {

        totalSupply_ = INITIAL_SUPPLY;

        
        preSale(company, companyTokens);
        preSale(team, teamTokens);
        preSale(crowdsale, crowdsaleTokens);
        preSale(bounty, bountyTokens);
    }

    function preSale(address _address, uint _amount) internal returns (bool) {
        balances[_address] = _amount;
        Transfer(address(0x0), _address, _amount);
    }

    function checkPermissions(address _from) internal constant returns (bool) {

        if (_from == team && now < unlockTime) {
            return false;
        }

        if (_from == bounty || _from == crowdsale || _from == company) {
            return true;
        }

        if (now < ITSEndTime) {
            return false;
        } else {
            return true;
        }

    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(checkPermissions(msg.sender));
        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(checkPermissions(_from));
        super.transferFrom(_from, _to, _value);
    }

    function () public payable {
        require(msg.value >= 1e16);
        beneficiary.transfer(msg.value);
    }

}