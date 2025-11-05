pragma solidity ^0.4.13;

contract VotingCenter {
  Poll[] public polls;

  event PollCreated(address indexed poll, address indexed author);

  







  function createPoll(
    bytes _ipfsHash,
    uint16 _numOptions,
    uint256 _startTime,
    uint256 _endTime
  ) public returns (address) {
    Poll newPoll = new Poll(_ipfsHash, _numOptions, _startTime, _endTime, msg.sender);
    polls.push(newPoll);

    PollCreated(address(newPoll), msg.sender);

    return address(newPoll);
  }

  function allPolls() view public returns (Poll[]) {
    return polls;
  }

  function numPolls() view public returns (uint256) {
    return polls.length;
  }
}