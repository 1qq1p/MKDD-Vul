pragma solidity ^0.4.8;
























contract PassContractor {
    
    
    PassProject passProject;
    
    
    address public creator;
    
    address public recipient;

    
    uint public smartContractStartDate;

    struct proposal {
        
        uint amount;
        
        string description;
        
        bytes32 hashOfTheDocument;
        
        uint dateOfProposal;
        
        uint submittedAmount;
        
        uint orderAmount;
        
        uint dateOfLastOrder;
    }
    
    proposal[] public proposals;



    event RecipientUpdated(address indexed By, address LastRecipient, address NewRecipient);
    event Withdrawal(address indexed By, address indexed Recipient, uint Amount);
    event ProposalAdded(address Creator, uint indexed ProposalID, uint Amount, string Description, bytes32 HashOfTheDocument);
    event ProposalSubmitted(address indexed Client, uint Amount);
    event Order(address indexed Client, uint indexed ProposalID, uint Amount);



    
    function Client() constant returns (address) {
        return passProject.Client();
    }

    
    function Project() constant returns (PassProject) {
        return passProject;
    }
    
    
    
    
    
    
    function proposalChecked(
        address _sender,
        uint _proposalID, 
        uint _amount) constant external onlyClient returns (bool) {
        if (_sender != recipient && _sender != creator) return;
        if (_amount <= proposals[_proposalID].amount - proposals[_proposalID].submittedAmount) return true;
    }

    
    function numberOfProposals() constant returns (uint) {
        return proposals.length - 1;
    }




    
    modifier onlyContractor {if (msg.sender != recipient) throw; _;}
    
    
    modifier onlyClient {if (msg.sender != Client()) throw; _;}



    function PassContractor(
        address _creator, 
        PassProject _passProject, 
        address _recipient,
        bool _restore) { 

        if (address(_passProject) == 0) throw;
        
        creator = _creator;
        if (_recipient == 0) _recipient = _creator;
        recipient = _recipient;
        
        passProject = _passProject;
        
        if (!_restore) smartContractStartDate = now;

        proposals.length = 1;
    }



    
    
    
    
    
    
    
    
    
    function cloneProposal(
        uint _amount,
        string _description,
        bytes32 _hashOfTheDocument,
        uint _dateOfProposal,
        uint _orderAmount,
        uint _dateOfOrder,
        bool _cloneOrder
    ) returns (bool success) {
            
        if (smartContractStartDate != 0 || recipient == 0
        || msg.sender != creator) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = _dateOfProposal;
        c.orderAmount = _orderAmount;
        c.dateOfLastOrder = _dateOfOrder;

        ProposalAdded(msg.sender, _proposalID, _amount, _description, _hashOfTheDocument);
        
        if (_cloneOrder) passProject.cloneOrder(address(this), _proposalID, _orderAmount, _dateOfOrder);
        
        return true;
    }

    
    
    function closeSetup() returns (bool) {
        
        if (smartContractStartDate != 0 
            || (msg.sender != creator && msg.sender != Client())) return;

        smartContractStartDate = now;

        return true;
    }
    


    
    
    function updateRecipient(address _newRecipient) onlyContractor {

        if (_newRecipient == 0) throw;

        RecipientUpdated(msg.sender, recipient, _newRecipient);
        recipient = _newRecipient;
    } 

    
    function () payable { }
    
    
    
    function withdraw(uint _amount) onlyContractor {
        if (!recipient.send(_amount)) throw;
        Withdrawal(msg.sender, recipient, _amount);
    }
    


    
    
    
    function updateProjectDescription(string _projectDescription, bytes32 _hashOfTheDocument) onlyContractor {
        passProject.updateDescription(_projectDescription, _hashOfTheDocument);
    }
    


    
    
    
    
    
    
    function newProposal(
        address _creator,
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) external returns (uint) {
        
        if (msg.sender == Client() && _creator != recipient && _creator != creator) throw;
        if (msg.sender != Client() && msg.sender != recipient && msg.sender != creator) throw;

        if (_amount == 0) throw;
        
        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = now;
        
        ProposalAdded(msg.sender, _proposalID, c.amount, c.description, c.hashOfTheDocument);
        
        return _proposalID;
    }
    
    
    
    
    
    function submitProposal(
        address _sender, 
        uint _proposalID, 
        uint _amount) onlyClient {

        if (_sender != recipient && _sender != creator) throw;    
        proposals[_proposalID].submittedAmount += _amount;
        ProposalSubmitted(msg.sender, _amount);
    }

    
    
    
    
    function order(
        uint _proposalID,
        uint _orderAmount
    ) external onlyClient returns (bool) {
    
        proposal c = proposals[_proposalID];
        
        uint _sum = c.orderAmount + _orderAmount;
        if (_sum > c.amount
            || _sum < c.orderAmount
            || _sum < _orderAmount) return; 

        c.orderAmount = _sum;
        c.dateOfLastOrder = now;
        
        Order(msg.sender, _proposalID, _orderAmount);
        
        return true;
    }
    
}
