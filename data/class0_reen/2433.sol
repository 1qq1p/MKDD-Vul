pragma solidity ^0.4.23;











interface IRegistry {
    function owner() external view returns (address _addr);
    function addressOf(bytes32 _name) external view returns (address _addr);
}

contract VideoPokerUtils {
    uint constant HAND_UNDEFINED = 0;
    uint constant HAND_RF = 1;
    uint constant HAND_SF = 2;
    uint constant HAND_FK = 3;
    uint constant HAND_FH = 4;
    uint constant HAND_FL = 5;
    uint constant HAND_ST = 6;
    uint constant HAND_TK = 7;
    uint constant HAND_TP = 8;
    uint constant HAND_JB = 9;
    uint constant HAND_HC = 10;
    uint constant HAND_NOT_COMPUTABLE = 11;

    
    
    

    
    
    function getHand(uint256 _hash)
        public
        pure
        returns (uint32)
    {
        
        return uint32(getCardsFromHash(_hash, 5, 0));
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function drawToHand(uint256 _hash, uint32 _hand, uint _draws)
        public
        pure
        returns (uint32)
    {
        
        assert(_draws <= 31);
        assert(_hand != 0 || _draws == 31);
        
        if (_draws == 0) return _hand;
        if (_draws == 31) return uint32(getCardsFromHash(_hash, 5, handToBitmap(_hand)));

        
        uint _newMask;
        for (uint _i=0; _i<5; _i++) {
            if (_draws & 2**_i == 0) continue;
            _newMask |= 63 * (2**(6*_i));
        }
        
        
        uint _discardMask = ~_newMask & (2**31-1);

        
        uint _newHand = getCardsFromHash(_hash, 5, handToBitmap(_hand));
        _newHand &= _newMask;
        _newHand |= _hand & _discardMask;
        return uint32(_newHand);
    }

    
    
    function getHandRank(uint32 _hand)
        public
        pure
        returns (uint)
    {
        if (_hand == 0) return HAND_NOT_COMPUTABLE;

        uint _card;
        uint[] memory _valCounts = new uint[](13);
        uint[] memory _suitCounts = new uint[](5);
        uint _pairVal;
        uint _minNonAce = 100;
        uint _maxNonAce = 0;
        uint _numPairs;
        uint _maxSet;
        bool _hasFlush;
        bool _hasAce;

        
        
        
        
        uint _i;
        uint _val;
        for (_i=0; _i<5; _i++) {
            _card = readFromCards(_hand, _i);
            if (_card > 51) return HAND_NOT_COMPUTABLE;
            
            
            _val = _card % 13;
            _valCounts[_val]++;
            _suitCounts[_card/13]++;
            if (_suitCounts[_card/13] == 5) _hasFlush = true;
            
            
            if (_val == 0) {
                _hasAce = true;
            } else {
                if (_val < _minNonAce) _minNonAce = _val;
                if (_val > _maxNonAce) _maxNonAce = _val;
            }

            
            if (_valCounts[_val] == 2) {
                if (_numPairs==0) _pairVal = _val;
                _numPairs++;
            } else if (_valCounts[_val] == 3) {
                _maxSet = 3;
            } else if (_valCounts[_val] == 4) {
                _maxSet = 4;
            }
        }

        if (_numPairs > 0){
            
            if (_maxSet==4) return HAND_FK;
            
            if (_maxSet==3 && _numPairs==2) return HAND_FH;
            
            if (_maxSet==3) return HAND_TK;
            
            if (_numPairs==2) return HAND_TP;
            
            if (_numPairs == 1 && (_pairVal >= 10 || _pairVal==0)) return HAND_JB;
            
            return HAND_HC;
        }

        
        bool _hasStraight = _hasAce
            
            ? _maxNonAce == 4 || _minNonAce == 9
            
            : _maxNonAce - _minNonAce == 4;
        
        
        if (_hasStraight && _hasFlush && _minNonAce==9) return HAND_RF;
        if (_hasStraight && _hasFlush) return HAND_SF;
        if (_hasFlush) return HAND_FL;
        if (_hasStraight) return HAND_ST;
        return HAND_HC;
    }

    
    function handToCards(uint32 _hand)
        public
        pure
        returns (uint8[5] _cards)
    {
        uint32 _mask;
        for (uint _i=0; _i<5; _i++){
            _mask = uint32(63 * 2**(6*_i));
            _cards[_i] = uint8((_hand & _mask) / (2**(6*_i)));
        }
    }



    
    
    

    function readFromCards(uint _cards, uint _index)
        internal
        pure
        returns (uint)
    {
        uint _offset = 2**(6*_index);
        uint _oneBits = 2**6 - 1;
        return (_cards & (_oneBits * _offset)) / _offset;
    }

    
    function handToBitmap(uint32 _hand)
        internal
        pure
        returns (uint _bitmap)
    {
        if (_hand == 0) return 0;
        uint _mask;
        uint _card;
        for (uint _i=0; _i<5; _i++){
            _mask = 63 * 2**(6*_i);
            _card = (_hand & _mask) / (2**(6*_i));
            _bitmap |= 2**_card;
        }
    }

    
    
    function getCardsFromHash(uint256 _hash, uint _numCards, uint _usedBitmap)
        internal
        pure
        returns (uint _cards)
    {
        
        if (_numCards == 0) return;

        uint _cardIdx = 0;                
        uint _card;                       
        uint _usedMask;                   

        while (true) {
            _card = _hash % 52;           
            _usedMask = 2**_card;         

            
            
            if (_usedBitmap & _usedMask == 0) {
                _cards |= (_card * 2**(_cardIdx*6));
                _usedBitmap |= _usedMask;
                _cardIdx++;
                if (_cardIdx == _numCards) return _cards;
            }

            
            _hash = uint256(keccak256(_hash));
        }
    }
}
