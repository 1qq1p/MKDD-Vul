pragma solidity ^0.4.18;





contract Encoder {
    enum Algorithm { sha, keccak }

    
    
    
    
    
    
    function generateProofSet(
        string seed,
        address caller,
        address receiver,
        address tokenAddress,
        Algorithm algorithm
    ) pure public returns(bytes32 hash, bytes32 operator, bytes32 check, address check_receiver, address check_token) {
        (hash, operator, check) = _escrow(seed, caller, receiver, tokenAddress, algorithm);
        bytes32 key = hash_seed(seed, algorithm);
        check_receiver = address(hash_data(key, algorithm)^operator);
        if (check_receiver == 0) check_receiver = caller;
        if (tokenAddress != 0) check_token = address(check^key^blind(receiver, algorithm));
    }

    
    function _escrow(
        string seed, 
        address caller,
        address receiver,
        address tokenAddress,
        Algorithm algorithm
    ) pure internal returns(bytes32 index, bytes32 operator, bytes32 check) {
        require(caller != receiver && caller != 0);
        bytes32 x = hash_seed(seed, algorithm);
        if (algorithm == Algorithm.sha) {
            index = sha256(x, caller);
            operator = sha256(x)^bytes32(receiver);
            check = x^sha256(receiver);
        } else {
            index = keccak256(x, caller);
            operator = keccak256(x)^bytes32(receiver);
            check = x^keccak256(receiver);
        }
        if (tokenAddress != 0) {
            check ^= bytes32(tokenAddress);
        }
    }
    
    
    function hash_seed(
        string seed, 
        Algorithm algorithm
    ) pure internal returns(bytes32) {
        if (algorithm == Algorithm.sha) return sha256(seed);
        else return keccak256(seed);
    }
    
   
    function hash_data(
        bytes32 key, 
        Algorithm algorithm
    ) pure internal returns(bytes32) {
        if (algorithm == Algorithm.sha) return sha256(key);
        else return keccak256(key);
    }
    
    
    function blind(
        address addr,
        Algorithm algorithm
    ) pure internal returns(bytes32) {
        if (algorithm == Algorithm.sha) return sha256(addr);
        else return keccak256(addr);
    }
    
}

