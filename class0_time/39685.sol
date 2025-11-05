

pragma solidity ^0.5.0;





library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.5.0;





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;








library ECDSA {
    




    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        
        if (signature.length != 65) {
            return (address(0));
        }

        
        
        
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
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

    




    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}



pragma solidity ^0.5.5;


library IndexedMerkleProof {
    function compute(bytes memory proof, uint160 leaf) internal pure returns (uint160 root, uint256 index) {
        uint160 computedHash = leaf;

        for (uint256 i = 0; i < proof.length / 20; i++) {
            uint160 proofElement;
            
            assembly {
                proofElement := div(mload(add(proof, add(32, mul(i, 20)))), 0x1000000000000000000000000)
            }

            if (computedHash < proofElement) {
                
                computedHash = uint160(uint256(keccak256(abi.encodePacked(computedHash, proofElement))));
                index += (1 << i);
            } else {
                
                computedHash = uint160(uint256(keccak256(abi.encodePacked(proofElement, computedHash))));
            }
        }

        return (computedHash, index);
    }
}



pragma solidity ^0.5.5;




contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    




    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    





    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    




    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    








    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    







    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    









    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    









    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    





    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    






    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    





    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    







    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}



pragma solidity ^0.5.0;




library CheckedERC20 {
    using SafeMath for uint;

    function isContract(IERC20 addr) internal view returns(bool result) {
        
        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal pure returns(bool result) {
        
        assembly {
            switch returndatasize()
            case 0 { 
                result := 1
            }
            case 32 { 
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { 
                revert(0, 0)
            }
        }
    }

    function handleReturnBytes32() internal pure returns(bytes32 result) {
        
        assembly {
            switch eq(returndatasize(), 32) 
            case 1 {
                returndatacopy(0, 0, 32)
                result := mload(0)
            }

            switch gt(returndatasize(), 32) 
            case 1 {
                returndatacopy(0, 64, 32)
                result := mload(0)
            }

            switch lt(returndatasize(), 32) 
            case 1 {
                revert(0, 0)
            }
        }
    }

    function asmTransfer(IERC20 token, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        
        (bool res,) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", to, value));
        require(res);
        return handleReturnBool();
    }

    function asmTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns(bool) {
        require(isContract(token));
        
        (bool res,) = address(token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value));
        require(res);
        return handleReturnBool();
    }

    function asmApprove(IERC20 token, address spender, uint256 value) internal returns(bool) {
        require(isContract(token));
        
        (bool res,) = address(token).call(abi.encodeWithSignature("approve(address,uint256)", spender, value));
        require(res);
        return handleReturnBool();
    }

    

    function checkedTransfer(IERC20 token, address to, uint256 value) internal {
        if (value > 0) {
            uint256 balance = token.balanceOf(address(this));
            asmTransfer(token, to, value);
            require(token.balanceOf(address(this)) == balance.sub(value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        if (value > 0) {
            uint256 toBalance = token.balanceOf(to);
            asmTransferFrom(token, from, to, value);
            require(token.balanceOf(to) == toBalance.add(value), "checkedTransfer: Final balance didn't match");
        }
    }
}



pragma solidity ^0.5.5;







