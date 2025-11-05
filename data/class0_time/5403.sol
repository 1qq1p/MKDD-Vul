pragma solidity ^0.4.18;

contract StandardToken is Token {
    using SafeMath for uint256;
    address newToken=0x0;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public _totalSupply=0;
    uint8 public decimals;                
    
    mapping(uint8 =>mapping(address=>bool)) internal whitelist;
    mapping(address=>uint8) internal whitelistModerator;
    
    uint256 public maxFee;
    uint256 public feePercantage;
    address public _owner;
    
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    modifier canModifyWhitelistIn {
        require(whitelistModerator[msg.sender]==1 || whitelistModerator[msg.sender]==3);
        _;
    }
    
    modifier canModifyWhitelistOut {
        require(whitelistModerator[msg.sender]==2 || whitelistModerator[msg.sender]==3);
        _;
    }
    
    modifier canModifyWhitelist {
        require(whitelistModerator[msg.sender]==3);
        _;
    }
    
    modifier onlyNewToken {
        require(msg.sender==newToken);
        _;
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if(newToken!=0x0){
            return NewToken(newToken).transfer(msg.sender,_to,_value);
        }
        uint256 fee=getFee(_value);
        uint256 valueWithFee=_value;
         if(withFee(msg.sender,_to)){
            valueWithFee=valueWithFee.add(fee);
        }
        if (balances[msg.sender] >= valueWithFee && _value > 0) {
            
            doTransfer(msg.sender,_to,_value,fee);
            return true;
        }  else { return false; }
    }
    
    function withFee(address _from,address _to) private returns(bool){
        return !whitelist[2][_from] && !whitelist[1][_to] && !whitelist[3][_to] && !whitelist[3][_from];
    }
    
    function getFee(uint256 _value) private returns (uint256){
        uint256 feeOfValue=_value.onePercent().mul(feePercantage);
        uint256 fee=uint256(maxFee).power(decimals);
         
        
        if (feeOfValue>= fee) {
            return fee;
        
        
        } 
        if (feeOfValue < fee) {
            return feeOfValue;
        }
    }
    function doTransfer(address _from,address _to,uint256 _value,uint256 fee) internal {
            balances[_from] =balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            if(withFee(_from,_to)) {
                doBurn(_from,fee);
            }
    }
    
    function doBurn(address _from,uint256 _value) private returns (bool success){
        require(balanceOf(_from) >= _value);   
        balances[_from] =balances[_from].sub(_value);            
        _totalSupply =_totalSupply.sub(_value);                      
        Burn(_from, _value);
        return true;
    }
    
    function burn(address _from,uint256 _value) onlyOwner public returns (bool success) {
        return doBurn(_from,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if(newToken!=0x0){
            return NewToken(newToken).transferFrom(msg.sender,_from,_to,_value);
        }
        uint256 fee=getFee(_value);
        uint256 valueWithFee=_value;
        if(withFee(_from,_to)){
            valueWithFee=valueWithFee.add(fee);
        }
        if (balances[_from] >= valueWithFee && 
            (allowed[_from][msg.sender] >= valueWithFee || allowed[_from][msg.sender] == _value) &&
            _value > 0 ) {
            doTransfer(_from,_to,_value,fee);
            if(allowed[_from][msg.sender] == _value){
                allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(_value);
            }
            else{
                allowed[_from][msg.sender] =allowed[_from][msg.sender].sub(valueWithFee);
            }
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        if(newToken!=0x0){
            return NewToken(newToken).approve(msg.sender,_spender,_value);
        }
        uint256 valueWithFee=_value;
        if(withFee(_spender,0x0)){
            uint256 fee=getFee(_value);  
            valueWithFee=valueWithFee.add(fee);
        }
        allowed[msg.sender][_spender] = valueWithFee;
        Approval(msg.sender, _spender, valueWithFee);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    function totalSupply() constant returns (uint totalSupply){
        return _totalSupply;
    }
    
    function setTotalSupply(uint256 _value) onlyNewToken external {
        _totalSupply=_value;
    }
    
    function setBalance(address _to,uint256 _value) onlyNewToken external {
        balances[_to]=_value;
    }
    
    function setAllowed(address _spender,address _to,uint256 _value) onlyNewToken external {
        allowed[_to][_spender]=_value;
    }
    function getDecimals() constant returns (uint256 decimals){
        return decimals;
    }
    
    function eventTransfer(address _from, address  _to, uint256 _value) onlyNewToken external{
        Transfer(_from,_to,_value);
    }
    
    function eventApproval(address _owner, address  _spender, uint256 _value)onlyNewToken external{
        Approval(_owner,_spender,_value);
    }
    function eventBurn(address from, uint256 value)onlyNewToken external{
        Burn(from,value);
    }
}

