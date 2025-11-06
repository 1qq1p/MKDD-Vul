pragma solidity ^0.4.13;

contract SmartzTokenLifecycleManager is ArgumentsChecker, multiowned, IDetachable, MintableToken, IEmissionPartMinter {
    using SafeMath for uint256;

    




    enum State {
        
        MINTING2PUBLIC_SALES,
        
        MINTING2POOLS,
        
        CIRCULATING_TOKEN
    }


    event StateChanged(State _state);


    modifier requiresState(State _state) {
        require(m_state == _state);
        _;
    }

    modifier onlyBy(address _from) {
        require(msg.sender == _from);
        _;
    }


    

    function SmartzTokenLifecycleManager(address[] _owners, uint _signaturesRequired, SmartzToken _SMR)
        public
        validAddress(_SMR)
        multiowned(_owners, _signaturesRequired)
    {
        m_SMR = _SMR;
    }


    
    function mint(address _to, uint256 _amount)
        public
        payloadSizeIs(32 * 2)
        validAddress(_to)
        requiresState(State.MINTING2PUBLIC_SALES)
        onlyBy(m_sale)
    {
        m_SMR.mint(_to, _amount);
    }

    
    function mintPartOfEmission(address to, uint part, uint partOfEmissionForPublicSales)
        public
        payloadSizeIs(32 * 3)
        validAddress(to)
        requiresState(State.MINTING2POOLS)
        onlyBy(m_pools)
    {
        uint poolTokens = m_publiclyDistributedTokens.mul(part).div(partOfEmissionForPublicSales);
        m_SMR.mint(to, poolTokens);
    }

    
    function detach()
        public
    {
        if (m_state == State.MINTING2PUBLIC_SALES) {
            require(msg.sender == m_sale);
            m_sale = address(0);
        }
        else if (m_state == State.MINTING2POOLS) {
            require(msg.sender == m_pools);
            m_pools = address(0);

            
            changeState(State.CIRCULATING_TOKEN);
            m_SMR.disableMinting();
            assert(m_SMR.startCirculation());
            m_SMR.detachControllerForever();
        }
        else {
            revert();
        }
    }


    

    
    function setSale(address sale)
        external
        payloadSizeIs(32)
        validAddress(sale)
        requiresState(State.MINTING2PUBLIC_SALES)
        onlymanyowners(keccak256(msg.data))
    {
        m_sale = sale;
    }

    
    function setPools(address pools)
        external
        payloadSizeIs(32)
        validAddress(pools)
        requiresState(State.MINTING2PUBLIC_SALES)
        onlymanyowners(keccak256(msg.data))
    {
        m_pools = pools;
    }

    
    function setSalesFinished()
        external
        requiresState(State.MINTING2PUBLIC_SALES)
        onlymanyowners(keccak256(msg.data))
    {
        require(m_pools != address(0));
        changeState(State.MINTING2POOLS);
        m_publiclyDistributedTokens = m_SMR.totalSupply();
    }


    

    
    function changeState(State _newState)
        private
    {
        assert(m_state != _newState);

        if (State.MINTING2PUBLIC_SALES == m_state) {    assert(State.MINTING2POOLS == _newState); }
        else if (State.MINTING2POOLS == m_state) {      assert(State.CIRCULATING_TOKEN == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);
    }


    

    
    SmartzToken public m_SMR;

    
    address public m_sale;

    
    address public m_pools;

    
    State public m_state = State.MINTING2PUBLIC_SALES;

    
    uint public m_publiclyDistributedTokens;
}