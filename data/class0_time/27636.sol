pragma solidity ^0.4.21;

contract CustodianCanBeReplaced is Zamok {

    
    struct CustodianChangeRequest {
        address proposedNew;
    }

    
    address public custodian;

    mapping (bytes32 => CustodianChangeRequest) public custodianChangeRequests;

    
    function CustodianCanBeReplaced(
        address _custodian
    )
    
	Zamok() public
    {
        custodian = _custodian;
    }

    
    modifier onlyCustodian {
        require(msg.sender == custodian);
        _;
    }

    
    

    function requestCustodianChange(address _proposedCustodian) public returns (bytes32 zamokId) {
        require(_proposedCustodian != address(0));

        zamokId = generateZamokId();

        custodianChangeRequests[zamokId] = CustodianChangeRequest({
            proposedNew: _proposedCustodian
        });

        emit CustodianChangeRequested(zamokId, msg.sender, _proposedCustodian);
    }

    function confirmCustodianChange(bytes32 _zamokId) public onlyCustodian {
        custodian = getCustodianChangeRequest(_zamokId);

        delete custodianChangeRequests[_zamokId];

        emit CustodianChangeConfirmed(_zamokId, custodian);
    }

    
    function getCustodianChangeRequest(bytes32 _zamokId) private view returns (address _proposedNew) {
        CustodianChangeRequest storage changeRequest = custodianChangeRequests[_zamokId];

        
        
        require(changeRequest.proposedNew != 0);

        return changeRequest.proposedNew;
    }

    event CustodianChangeRequested(
        bytes32 _zamokId,
        address _msgSender,
        address _proposedCustodian
    );

    event CustodianChangeConfirmed(bytes32 _zamokId, address _newCustodian);
}

