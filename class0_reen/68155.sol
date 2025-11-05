pragma solidity ^0.5.0;


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    


    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    



    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


contract TokenCapCrowdsale is BaseCrowdsale {
    uint256 public tokenCap;
    uint256 public individualCap;
    uint256 public totalSupply;

    modifier greaterThanZero(uint256 value) {
        require(value > 0);
        _;
    }

    constructor (uint256 _cap, uint256 _individualCap)
        public
        greaterThanZero(_cap)
        greaterThanZero(_individualCap)
    {
        syncTotalSupply();
        require(totalSupply < _cap);
        tokenCap = _cap;
        individualCap = _individualCap;
    }

    function setIndividualCap(uint256 _newIndividualCap)
        external
        onlyOwner
    {     
        individualCap = _newIndividualCap;
    }

    function setTokenCap(uint256 _newTokenCap)
        external
        onlyOwner
    {     
        tokenCap = _newTokenCap;
    }

    function hasEnded() public view returns (bool) {
        bool tokenCapReached = totalSupply >= tokenCap;
        return tokenCapReached || super.hasEnded();
    }

    function checkAndUpdateSupply(uint256 newSupply) internal returns (bool) {
        totalSupply = newSupply;
        return tokenCap >= totalSupply;
    }

    function withinIndividualCap(uint256 _tokens) internal view returns (bool) {
        return individualCap >= _tokens;
    }

    function syncTotalSupply() internal {
        totalSupply = token.totalSupply();
    }
}


