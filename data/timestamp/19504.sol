pragma solidity ^0.5.10;


contract ERC20ImplUpgradeable is CustodianUpgradeable  {

   
    struct ImplChangeRequest {
        address proposedNew;
    }

   
    ERC20Impl public erc20Impl;

   
    mapping (bytes32 => ImplChangeRequest) public implChangeReqs;

   
    constructor(address _custodian) CustodianUpgradeable(_custodian) public {
        erc20Impl = ERC20Impl(0x0);
    }

   
    modifier onlyImpl {
        require(msg.sender == address(erc20Impl));
        _;
    }

    
    function requestImplChange(address _proposedImpl) public returns (bytes32 lockId) {
        require(_proposedImpl != address(0));

        lockId = generateLockId();

        implChangeReqs[lockId] = ImplChangeRequest({
            proposedNew: _proposedImpl
        });

        emit ImplChangeRequested(lockId, msg.sender, _proposedImpl);
    }

   
    function confirmImplChange(bytes32 _lockId) public onlyCustodian {
        erc20Impl = getImplChangeReq(_lockId);

        delete implChangeReqs[_lockId];

        emit ImplChangeConfirmed(_lockId, address(erc20Impl));
    }

    
    function getImplChangeReq(bytes32 _lockId) private view returns (ERC20Impl _proposedNew) {
        ImplChangeRequest storage changeRequest = implChangeReqs[_lockId];

     
        require(changeRequest.proposedNew != address(0));

        return ERC20Impl(changeRequest.proposedNew);
    }

  
    event ImplChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedImpl
    );

    
    event ImplChangeConfirmed(bytes32 _lockId, address _newImpl);
}
