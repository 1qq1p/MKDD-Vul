pragma solidity ^0.4.0;






contract Notifier is withOwners, withAccounts {
  string public xIPFSPublicKey;
  uint public minEthPerNotification = 0.02 ether;

  struct Task {
    address sender;
    uint8 state; 
                 
                 
                 
                 

    bool isxIPFS;  
  }

  struct Notification {
    uint8 transport; 
    string destination;
    string message;
  }

  mapping(uint => Task) public tasks;
  mapping(uint => Notification) public notifications;
  mapping(uint => string) public xnotifications; 
  uint public tasksCount = 0;

  


  event TaskUpdated(uint id, uint8 state);

  function Notifier(string _xIPFSPublicKey) public {
    xIPFSPublicKey = _xIPFSPublicKey;
    ownersCount++;
    owners[msg.sender] = true;
  }







  


  function notify(uint8 _transport, string _destination, string _message) public payable handleDeposit {
    if (_transport != 1 && _transport != 2) {
      throw;
    }

    uint id = tasksCount;
    uint8 state = 10; 

    createTx(id, msg.sender, minEthPerNotification);
    notifications[id] = Notification({
      transport: _transport,
      destination: _destination,
      message: _message
    });
    tasks[id] = Task({
      sender: msg.sender,
      state: state,
      isxIPFS: false 
    });

    TaskUpdated(id, state);
    ++tasksCount;
  }









  function xnotify(string _hash) public payable handleDeposit {
    uint id = tasksCount;
    uint8 state = 10; 

    createTx(id, msg.sender, minEthPerNotification);
    xnotifications[id] = _hash;
    tasks[id] = Task({
      sender: msg.sender,
      state: state,
      isxIPFS: true
    });

    TaskUpdated(id, state);
    ++tasksCount;
  }







  function updateMinEthPerNotification(uint _newMin) public onlyManagers {
    minEthPerNotification = _newMin;
  }

  



  function taskProcessedNoCosting(uint _id) public onlyManagers {
    updateState(_id, 20, 0);
  }

  



  function taskProcessedWithCosting(uint _id, uint _cost) public onlyManagers {
    updateState(_id, 50, _cost);
  }

  



  function taskRejected(uint _id, uint _cost) public onlyManagers {
    updateState(_id, 60, _cost);
  }

  


  function updateXIPFSPublicKey(string _publicKey) public onlyOwners {
    xIPFSPublicKey = _publicKey;
  }

  function updateState(uint _id, uint8 _state, uint _cost) internal {
    if (tasks[_id].state == 0 || tasks[_id].state >= 50) {
      throw;
    }

    tasks[_id].state = _state;

    
    if (_state >= 50) {
      settle(_id, _cost);
    }
    TaskUpdated(_id, _state);
  }

  


  function () payable handleDeposit {
  }
}