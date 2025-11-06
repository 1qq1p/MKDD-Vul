pragma solidity ^0.4.24;








contract Whitelistable is Administratable {
    event WhitelistedTransferer(address indexed _transferer, bool _allowTransfer);
	mapping (address => bool) public whitelistedTransferer;

    function setWhitelistedTransferer(address _transferer, bool _allowTransfer) public onlySuperAdmins validateAddress(_transferer) returns (bool) {
        require(_allowTransfer != whitelistedTransferer[_transferer]);
        whitelistedTransferer[_transferer] = _allowTransfer;
        emit WhitelistedTransferer(_transferer, _allowTransfer);
        return true;
    }
}


