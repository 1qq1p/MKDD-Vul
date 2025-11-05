pragma solidity ^0.4.24;






contract SettlementRegistry is Ownable {
    string public VERSION; 

    struct SettlementDetails {
        bool registered;
        Settlement settlementContract;
        BrokerVerifier brokerVerifierContract;
    }

    
    mapping(uint64 => SettlementDetails) public settlementDetails;

    
    event LogSettlementRegistered(uint64 settlementID, Settlement settlementContract, BrokerVerifier brokerVerifierContract);
    event LogSettlementUpdated(uint64 settlementID, Settlement settlementContract, BrokerVerifier brokerVerifierContract);
    event LogSettlementDeregistered(uint64 settlementID);

    
    
    
    constructor(string _VERSION) public {
        VERSION = _VERSION;
    }

    
    function settlementRegistration(uint64 _settlementID) external view returns (bool) {
        return settlementDetails[_settlementID].registered;
    }

    
    function settlementContract(uint64 _settlementID) external view returns (Settlement) {
        return settlementDetails[_settlementID].settlementContract;
    }

    
    function brokerVerifierContract(uint64 _settlementID) external view returns (BrokerVerifier) {
        return settlementDetails[_settlementID].brokerVerifierContract;
    }

    
    
    
    
    function registerSettlement(uint64 _settlementID, Settlement _settlementContract, BrokerVerifier _brokerVerifierContract) public onlyOwner {
        bool alreadyRegistered = settlementDetails[_settlementID].registered;
        
        settlementDetails[_settlementID] = SettlementDetails({
            registered: true,
            settlementContract: _settlementContract,
            brokerVerifierContract: _brokerVerifierContract
        });

        if (alreadyRegistered) {
            emit LogSettlementUpdated(_settlementID, _settlementContract, _brokerVerifierContract);
        } else {
            emit LogSettlementRegistered(_settlementID, _settlementContract, _brokerVerifierContract);
        }
    }

    
    
    function deregisterSettlement(uint64 _settlementID) external onlyOwner {
        require(settlementDetails[_settlementID].registered, "not registered");

        delete settlementDetails[_settlementID];

        emit LogSettlementDeregistered(_settlementID);
    }
}








library ECRecovery {

  




  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    
    if (sig.length != 65) {
      return (address(0));
    }

    
    
    
    
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    
    if (v < 27) {
      v += 27;
    }

    
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      
      return ecrecover(hash, v, r, s);
    }
  }

  




  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    
    
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}

library Utils {

    




    function uintToBytes(uint256 _v) internal pure returns (bytes) {
        uint256 v = _v;
        if (v == 0) {
            return "0";
        }

        uint256 digits = 0;
        uint256 v2 = v;
        while (v2 > 0) {
            v2 /= 10;
            digits += 1;
        }

        bytes memory result = new bytes(digits);

        for (uint256 i = 0; i < digits; i++) {
            result[digits - i - 1] = bytes1((v % 10) + 48);
            v /= 10;
        }

        return result;
    }

    





    function addr(bytes _hash, bytes _signature) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        bytes memory encoded = abi.encodePacked(prefix, uintToBytes(_hash.length), _hash);
        bytes32 prefixedHash = keccak256(encoded);

        return ECRecovery.recover(prefixedHash, _signature);
    }

}




