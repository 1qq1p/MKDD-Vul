pragma solidity ^0.4.16;




interface dAppBridge_I {
    function getOwner() external returns(address);
    function getMinReward(string requestType) external returns(uint256);
    function getMinGas() external returns(uint256);    
    
    function callURL(string callback_method, string external_url, string external_params, string json_extract_element) external payable returns(bytes32);
}
contract clientOfdAppBridge {
    address internal _dAppBridgeLocator_Prod_addr = 0x5b63e582645227F1773bcFaE790Ea603dB948c6A;
    
    DappBridgeLocator_I internal dAppBridgeLocator;
    dAppBridge_I internal dAppBridge; 
    uint256 internal current_gas = 0;
    uint256 internal user_callback_gas = 0;
    
    function initBridge() internal {
        
        if(address(dAppBridgeLocator) != _dAppBridgeLocator_Prod_addr){ 
            dAppBridgeLocator = DappBridgeLocator_I(_dAppBridgeLocator_Prod_addr);
        }
        
        if(address(dAppBridge) != dAppBridgeLocator.currentLocation()){
            dAppBridge = dAppBridge_I(dAppBridgeLocator.currentLocation());
        }
        if(current_gas == 0) {
            current_gas = dAppBridge.getMinGas();
        }
    }

    modifier dAppBridgeClient {
        initBridge();

        _;
    }
    

    event event_senderAddress(
        address senderAddress
    );
    
    event evnt_dAdppBridge_location(
        address theLocation
    );
    
    event only_dAppBridgeCheck(
        address senderAddress,
        address checkAddress
    );
    
    modifier only_dAppBridge_ {
        initBridge();
        
        
        
        emit only_dAppBridgeCheck(msg.sender, address(dAppBridge));
        require(msg.sender == address(dAppBridge));
        _;
    }

    
    modifier only_dAppBridge {
        initBridge();
        address _dAppBridgeOwner = dAppBridge.getOwner();
        require(msg.sender == _dAppBridgeOwner);

        _;
    }
    

    
    function setGas(uint256 new_gas) internal {
        require(new_gas > 0);
        current_gas = new_gas;
    }

    function setCallbackGas(uint256 new_callback_gas) internal {
        require(new_callback_gas > 0);
        user_callback_gas = new_callback_gas;
    }

    

    function callURL(string callback_method, string external_url, string external_params) internal dAppBridgeClient returns(bytes32) {
        uint256 _reward = dAppBridge.getMinReward('callURL')+user_callback_gas;
        return dAppBridge.callURL.value(_reward).gas(current_gas)(callback_method, external_url, external_params, "");
    }
    function callURL(string callback_method, string external_url, string external_params, string json_extract_elemen) internal dAppBridgeClient returns(bytes32) {
        uint256 _reward = dAppBridge.getMinReward('callURL')+user_callback_gas;
        return dAppBridge.callURL.value(_reward).gas(current_gas)(callback_method, external_url, external_params, json_extract_elemen);
    }


    
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function char(byte b) internal pure returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
    
    function bytes32string(bytes32 b32) internal pure returns (string out) {
        bytes memory s = new bytes(64);
        for (uint8 i = 0; i < 32; i++) {
            byte b = byte(b32[i]);
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[i*2] = char(hi);
            s[i*2+1] = char(lo);            
        }
        out = string(s);
    }

    function compareStrings (string a, string b) internal pure returns (bool){
        return keccak256(a) == keccak256(b);
    }
    
    function concatStrings(string _a, string _b) internal pure returns (string){
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory length_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_c = bytes(length_ab);
        uint k = 0;
        for (uint i = 0; i < bytes_a.length; i++) bytes_c[k++] = bytes_a[i];
        for (i = 0; i < bytes_b.length; i++) bytes_c[k++] = bytes_b[i];
        return string(bytes_c);
    }
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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






