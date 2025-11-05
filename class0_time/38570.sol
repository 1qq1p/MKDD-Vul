pragma solidity ^0.4.25;














contract PriceFeed is PriceFeedInterface, Operated {
    string public name;
    uint public rate;
    bool public live;

    event SetRate(uint oldRate, bool oldLive, uint newRate, bool newLive);

    constructor(string _name, uint _rate, bool _live) public {
        initOperated(msg.sender);
        name = _name;
        rate = _rate;
        live = _live;
        emit SetRate(0, false, rate, live);
    }
    function setRate(uint _rate, bool _live) public onlyOperator {
        emit SetRate(rate, live, _rate, _live);
        rate = _rate;
        live = _live;
    }
    function getRate() public view returns (uint _rate, bool _live) {
        return (rate, live);
    }
}