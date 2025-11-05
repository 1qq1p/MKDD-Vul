


pragma solidity ^0.5.0;



contract ITokenMinimal {
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function deposit() public payable;
    function withdraw(uint value) public;
}



pragma solidity ^0.5.2;




library Address {
    






    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.2;





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



library SafeERC20 {
    using Address for address;

    bytes4 constant private TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 constant private TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    bytes4 constant private APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));

    function safeTransfer(address _erc20Addr, address _to, uint256 _value) internal {

        
        require(_erc20Addr.isContract(), "ERC20 is not a contract");

        (bool success, bytes memory returnValue) =
        
        _erc20Addr.call(abi.encodeWithSelector(TRANSFER_SELECTOR, _to, _value));
        
        require(success, "safeTransfer must succeed");
        
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)), "safeTransfer must return nothing or true");
    }

    function safeTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal {

        
        require(_erc20Addr.isContract(), "ERC20 is not a contract");

        (bool success, bytes memory returnValue) =
        
        _erc20Addr.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, _from, _to, _value));
        
        require(success, "safeTransferFrom must succeed");
        
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)), "safeTransferFrom must return nothing or true");
    }

    function safeApprove(address _erc20Addr, address _spender, uint256 _value) internal {

        
        require(_erc20Addr.isContract(), "ERC20 is not a contract");

        
        
        
        





        (bool success, bytes memory returnValue) =
        
        _erc20Addr.call(abi.encodeWithSelector(APPROVE_SELECTOR, _spender, _value));
        
        require(success, "safeApprove must succeed");
        
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)),  "safeApprove must return nothing or true");
    }
}



pragma solidity ^0.5.2;





