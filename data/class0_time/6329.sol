pragma solidity ^0.4.18;








contract BatchToken is ControlledToken {

    













    function transferBatchIdempotent(address[] _toArray, uint256[] _amountArray, bool _expectZero)
        
        public
    {
        
        uint256 _count = _toArray.length;
        require(_amountArray.length == _count);

        for (uint256 i = 0; i < _count; i++) {
            address _to = _toArray[i];
            
            if(!_expectZero || (balanceOf(_to) == 0)) {
                transfer(_to, _amountArray[i]);
            }
        }
    }

}




