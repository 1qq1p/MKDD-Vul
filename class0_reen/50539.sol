

















pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;




contract LibRelayer {

    


    mapping (address => mapping (address => bool)) public relayerDelegates;

    


    mapping (address => bool) hasExited;

    event RelayerApproveDelegate(address indexed relayer, address indexed delegate);
    event RelayerRevokeDelegate(address indexed relayer, address indexed delegate);

    event RelayerExit(address indexed relayer);
    event RelayerJoin(address indexed relayer);

    


    function approveDelegate(address delegate) external {
        relayerDelegates[msg.sender][delegate] = true;
        emit RelayerApproveDelegate(msg.sender, delegate);
    }

    


    function revokeDelegate(address delegate) external {
        relayerDelegates[msg.sender][delegate] = false;
        emit RelayerRevokeDelegate(msg.sender, delegate);
    }

    


    function canMatchOrdersFrom(address relayer) public view returns(bool) {
        return msg.sender == relayer || relayerDelegates[relayer][msg.sender] == true;
    }

    


    function joinIncentiveSystem() external {
        delete hasExited[msg.sender];
        emit RelayerJoin(msg.sender);
    }

    




    function exitIncentiveSystem() external {
        hasExited[msg.sender] = true;
        emit RelayerExit(msg.sender);
    }

    


    function isParticipant(address relayer) public view returns(bool) {
        return !hasExited[relayer];
    }
}



