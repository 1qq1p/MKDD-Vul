pragma solidity ^0.4.19;


contract HorseControl  {

    address public ceoAddress=0xC229F1e3D3a798725e09dbC6b31b20c07b95543B;
    address public ctoAddress=0x01569f2D20499ad013daE86B325EE30cB582c3Ba;
 

    modifier onCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    modifier onCTO() {
        require(msg.sender == ctoAddress);
        _;
    }

    modifier onlyC() {
        require(
            msg.sender == ceoAddress ||
            msg.sender == ctoAddress
        );
        _;
    }

 
}

