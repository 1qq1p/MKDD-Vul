pragma solidity ^0.5.2;




interface RegistryInterface {
    function logic(address logicAddr) external view returns (bool);
    function record(address currentOwner, address nextOwner) external;
}





contract AddressRecord {

    


    address public registry;

    


    modifier logicAuth(address logicAddr) {
        require(logicAddr != address(0), "logic-proxy-address-required");
        require(RegistryInterface(registry).logic(logicAddr), "logic-not-authorised");
        _;
    }

}




