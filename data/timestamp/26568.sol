









contract daylimit is multiowned {

    

    
    modifier limitedDaily(uint _value) {
        if (underLimit(_value))
            _;
    }

    

    
    function daylimit(uint _limit) {
        m_dailyLimit = _limit;
        m_lastDay = today();
    }
    
    function setDailyLimit(uint _newLimit) onlymanyowners(sha3(msg.data, block.number)) external {
        m_dailyLimit = _newLimit;
    }
    
    function resetSpentToday() onlymanyowners(sha3(msg.data, block.number)) external {
        m_spentToday = 0;
    }
    
    
    
    
    
    function underLimit(uint _value) internal onlyowner returns (bool) {
        
        if (today() > m_lastDay) {
            m_spentToday = 0;
            m_lastDay = today();
        }
        
        if (m_spentToday + _value >= m_spentToday && m_spentToday + _value <= m_dailyLimit) {
            m_spentToday += _value;
            return true;
        }
        return false;
    }
    
    function today() private constant returns (uint) { return now / 1 days; }

    

    uint public m_dailyLimit;
    uint public m_spentToday;
    uint public m_lastDay;
}

