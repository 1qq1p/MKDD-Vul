



























pragma solidity ^0.4.17;


contract TestyTest is
    ReentryProtected,
    ERC20Token,
    TestyTestAbstract,
    TestyTestConfig
{
    using SafeMath for uint;





    
    uint constant TOKEN = uint(10)**decimals;






    function TestyTest()
        public
    {

        owner = OWNER;
        totalSupply = TOTAL_TOKENS.mul(TOKEN);
        balances[owner] = totalSupply;

    }

    
    function ()
        public
        payable
    {
        
    }






event LowerSupply(address indexed burner, uint256 value);
event IncreaseSupply(address indexed burner, uint256 value);

    




    function lowerSupply(uint256 _value)
        public
        onlyOwner
        preventReentry() {
            require(_value > 0);
            address burner = 0x41CaE184095c5DAEeC5B2b2901D156a029B3dAC6;
            balances[burner] = balances[burner].sub(_value);
            totalSupply = totalSupply.sub(_value);
            emit LowerSupply(msg.sender, _value);
    }

    function increaseSupply(uint256 _value)
        public
        onlyOwner
        preventReentry() {
            require(_value > 0);
            totalSupply = totalSupply.add(_value);
            emit IncreaseSupply(msg.sender, _value);
    }





    function clearKyc(address[] _addrs)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        uint len = _addrs.length;
        for(uint i; i < len; i++) {
            clearedKyc[_addrs[i]] = true;
            emit Kyc(_addrs[i], true);
        }
        return true;
    }





    function requireKyc(address[] _addrs)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        uint len = _addrs.length;
        for(uint i; i < len; i++) {
            delete clearedKyc[_addrs[i]];
            emit Kyc(_addrs[i], false);
        }
        return true;
    }






    
    function transferToMany(address[] _addrs, uint[] _amounts)
        public
        noReentry
        returns (bool)
    {
        require(_addrs.length == _amounts.length);
        uint len = _addrs.length;
        for(uint i = 0; i < len; i++) {
            xfer(msg.sender, _addrs[i], _amounts[i]);
        }
        return true;
    }

   
    function xfer(address _from, address _to, uint _amount)
        internal
        noReentry
        returns (bool)
    {
        super.xfer(_from, _to, _amount);
        return true;
    }





    
    function changeOwner(address _owner)
        public
        onlyOwner
        returns (bool)
    {
        emit ChangeOwnerTo(_owner);
        newOwner = _owner;
        return true;
    }

    
    function acceptOwnership()
        public
        returns (bool)
    {
        require(msg.sender == newOwner);
        emit ChangedOwner(owner, msg.sender);
        owner = newOwner;
        delete newOwner;
        return true;
    }


    
    function transferExternalToken(address _kAddr, address _to, uint _amount)
        public
        onlyOwner
        preventReentry
        returns (bool)
    {
        require(ERC20Token(_kAddr).transfer(_to, _amount));
        return true;
    }


}