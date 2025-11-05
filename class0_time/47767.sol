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







contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    




    


    mapping(bytes4 => bool) private _supportedInterfaces;

    



    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    


    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    


    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}






