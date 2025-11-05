



pragma solidity ^0.4.25;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}





library SafeMath {

    





    function mul64(uint256 a, uint256 b) internal pure returns (uint64) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        require(c < 2**64);
        return uint64(c);
    }

    





    function div64(uint256 a, uint256 b) internal pure returns (uint64) {
        uint256 c = a / b;
        require(c < 2**64);
        
        return uint64(c);
    }

    





    function sub64(uint256 a, uint256 b) internal pure returns (uint64) {
        require(b <= a);
        uint256 c = a - b;
        require(c < 2**64);
        
        return uint64(c);
    }

    





    function add64(uint256 a, uint256 b) internal pure returns (uint64) {
        uint256 c = a + b;
        require(c >= a && c < 2**64);
        
        return uint64(c);
    }

    





    function mul32(uint256 a, uint256 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        require(c < 2**32);
        
        return uint32(c);
    }

    





    function div32(uint256 a, uint256 b) internal pure returns (uint32) {
        uint256 c = a / b;
        require(c < 2**32);
        
        return uint32(c);
    }

    





    function sub32(uint256 a, uint256 b) internal pure returns (uint32) {
        require(b <= a);
        uint256 c = a - b;
        require(c < 2**32);
        
        return uint32(c);
    }

    





    function add32(uint256 a, uint256 b) internal pure returns (uint32) {
        uint256 c = a + b;
        require(c >= a && c < 2**32);
        return uint32(c);
    }

    





    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        
        return c;
    }

    





    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        
        return c;
    }

    





    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    





    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}






library Merkle {

    





    function combinedHash(bytes32 a, bytes32 b) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(a, b));
    }

    
















    function getProofRootHash(bytes32[] memory proof, uint256 key, bytes32 leaf) public pure returns(bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(leaf));
        uint256 k = key;
        for(uint i = 0; i<proof.length; i++) {
            uint256 bit = k % 2;
            k = k / 2;

            if (bit == 0)
                hash = combinedHash(hash, proof[i]);
            else
                hash = combinedHash(proof[i], hash);
        }
        return hash;
    }
}




contract BatPay is Payments {

    














    constructor(
        IERC20 token_,
        uint32 maxBulk,
        uint32 maxTransfer,
        uint32 challengeBlocks,
        uint32 challengeStepBlocks,
        uint64 collectStake,
        uint64 challengeStake,
        uint32 unlockBlocks,
        uint64 maxCollectAmount
    )
        public
    {
        require(token_ != address(0), "Token address can't be zero");
        require(maxBulk > 0, "Parameter maxBulk can't be zero");
        require(maxTransfer > 0, "Parameter maxTransfer can't be zero");
        require(challengeBlocks > 0, "Parameter challengeBlocks can't be zero");
        require(challengeStepBlocks > 0, "Parameter challengeStepBlocks can't be zero");
        require(collectStake > 0, "Parameter collectStake can't be zero");
        require(challengeStake > 0, "Parameter challengeStake can't be zero");
        require(unlockBlocks > 0, "Parameter unlockBlocks can't be zero");
        require(maxCollectAmount > 0, "Parameter maxCollectAmount can't be zero");

        owner = msg.sender;
        token = IERC20(token_);
        params.maxBulk = maxBulk;
        params.maxTransfer = maxTransfer;
        params.challengeBlocks = challengeBlocks;
        params.challengeStepBlocks = challengeStepBlocks;
        params.collectStake = collectStake;
        params.challengeStake = challengeStake;
        params.unlockBlocks = unlockBlocks;
        params.maxCollectAmount = maxCollectAmount;
    }
}