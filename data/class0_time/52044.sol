pragma solidity ^0.5.7;





library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract TokenStandard is ERC20, TokenBasic {
    
    mapping(address => mapping(address => uint256)) internal allowed;

    function transferFrom(address payable _from, address payable _to, uint256 _value) public onlyPayloadSize(3 * 32) returns(bool) {
        require(_to != address(0));
        require(_to != found);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        uint256 div1 = 0;
        uint256 div2 = 0;
        if (_from != found) {
            if (pdat_[_from] < pnr_) {
                for (uint256 i = pnr_; i >= pdat_[_from]; i = i.sub(1)) {
                    div1 = div1.add(sum_[i].mul(balances[_from]));
                }
            }
        }
        if (pdat_[_to] < pnr_ && balances[_to] > 0) {
            for (uint256 i = pnr_; i >= pdat_[_to]; i = i.sub(1)) {
                div2 = div2.add(sum_[i].mul(balances[_to]));
            }
        }
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        pdat_[_to] = pnr_;
        
        emit Transfer(_from, _to, _value);
        if (_from == found) {
            activeSupply_ = activeSupply_.add(_value);
        } else {
            pdat_[_from] = pnr_;
            if (div1 > 0) {
                _from.transfer(div1);
            }
        }
        if (div2 > 0) {
            _to.transfer(div2);
        }
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addrdedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addrdedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}
