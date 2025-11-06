pragma solidity ^0.4.21;


































contract AcceptsDailyDivs {
    DailyDivs public tokenContract;

    function AcceptsDailyDivs(address _tokenContract) public {
        tokenContract = DailyDivs(_tokenContract);
    }

    modifier onlyTokenContract {
        require(msg.sender == address(tokenContract));
        _;
    }

    






    function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}

