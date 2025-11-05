pragma solidity ^0.4.23;




contract Utils {
    string constant public contract_version = "0.4.0";

    
    
    
    
    function contractExists(address contract_address) public view returns (bool) {
        uint size;

        assembly {
            size := extcodesize(contract_address)
        }

        return size > 0;
    }
}


interface Token {

    
    function totalSupply() external view returns (uint256 supply);

    
    
    function balanceOf(address _owner) external view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) external returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) external returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    function decimals() external view returns (uint8 decimals);
}


library ECVerify {

    function ecverify(bytes32 hash, bytes signature)
        internal
        pure
        returns (address signature_address)
    {
        require(signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        
        
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))

            
            v := byte(0, mload(add(signature, 96)))
        }

        
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28);

        signature_address = ecrecover(hash, v, r, s);

        
        require(signature_address != address(0x0));

        return signature_address;
    }
}




