pragma solidity ^0.5.5;







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









contract BaseERC20Token is ERC20Detailed, ERC20Capped, ERC20Burnable, OperatorRole, TokenRecover {

    event MintFinished();
    event TransferEnabled();

    
    bool private _mintingFinished = false;

    
    bool private _transferEnabled = false;

    


    modifier canMint() {
        require(!_mintingFinished);
        _;
    }

    


    modifier canTransfer(address from) {
        require(_transferEnabled || isOperator(from));
        _;
    }

    






    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 cap,
        uint256 initialSupply
    )
        public
        ERC20Detailed(name, symbol, decimals)
        ERC20Capped(cap)
    {
        if (initialSupply > 0) {
            _mint(owner(), initialSupply);
        }
    }

    


    function mintingFinished() public view returns (bool) {
        return _mintingFinished;
    }

    


    function transferEnabled() public view returns (bool) {
        return _transferEnabled;
    }

    function mint(address to, uint256 value) public canMint returns (bool) {
        return super.mint(to, value);
    }

    function transfer(address to, uint256 value) public canTransfer(msg.sender) returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public canTransfer(from) returns (bool) {
        return super.transferFrom(from, to, value);
    }

    


    function finishMinting() public onlyOwner canMint {
        _mintingFinished = true;
        _transferEnabled = true;

        emit MintFinished();
        emit TransferEnabled();
    }

    


    function enableTransfer() public onlyOwner {
        _transferEnabled = true;

        emit TransferEnabled();
    }

    



    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }

    



    function removeMinter(address account) public onlyOwner {
        _removeMinter(account);
    }
}







