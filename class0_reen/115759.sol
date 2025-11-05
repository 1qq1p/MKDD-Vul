pragma solidity 0.4.17;

library IdeaUint {

    function add(uint a, uint b) constant internal returns (uint result) {
        uint c = a + b;

        assert(c >= a);

        return c;
    }

    function sub(uint a, uint b) constant internal returns (uint result) {
        uint c = a - b;

        assert(b <= a);

        return c;
    }

    function mul(uint a, uint b) constant internal returns (uint result) {
        uint c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint a, uint b) constant internal returns (uint result) {
        uint c = a / b;

        return c;
    }
}

contract ProjectAgent {

    address public owner;
    address public coin;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCoin() {
        require(msg.sender == coin);
        _;
    }

    function ProjectAgent() {
        owner = msg.sender;
    }

    function makeProject(
    address _owner,
    string _name,
    uint _required,
    uint _requiredDays
    ) public returns (address _address) {
        return address(
        new IdeaProject(
        _owner,
        _name,
        _required,
        _requiredDays
        )
        );
    }

    function setCoin(address _coin) public onlyOwner {
        coin = _coin;
    }

    function withdrawFromProject(
    address _owner,
    address _project,
    uint _stage
    ) public onlyCoin returns (bool _success, uint _value) {
        require(_owner == IdeaProject(_project).owner());

        IdeaProject project = IdeaProject(_project);
        updateFundingStateIfNeed(_project);

        if (project.isWorkflowState() || project.isSuccessDoneState()) {
            _value = project.withdraw(_stage);

            if (_value > 0) {
                _success = true;
            } else {
                _success = false;
            }
        } else {
            _success = false;
        }
    }

    function cashBackFromProject(
    address _owner,
    address _project
    ) public onlyCoin returns (bool _success, uint _value) {
        IdeaProject project = IdeaProject(_project);

        updateFundingStateIfNeed(_project);

        if (
        project.isFundingFailState() ||
        project.isWorkFailState()
        ) {
            _value = project.calcInvesting(_owner);
            _success = true;
        } else {
            _success = false;
        }
    }

    function updateFundingStateIfNeed(address _project) internal {
        IdeaProject project = IdeaProject(_project);

        if (
        project.isFundingState() &&
        now > project.fundingEndTime()
        ) {
            if (project.earned() >= project.required()) {
                project.projectWorkStarted();
            } else {
                project.projectFundingFail();
            }
        }
    }

    function buyProduct(address _product, address _account, uint _amount) public onlyCoin {
        IdeaSubCoin _productContract = IdeaSubCoin(_product);
        address _project = _productContract.project();
        IdeaProject _projectContract = IdeaProject(_project);

        updateFundingStateIfNeed(_project);
        require(_projectContract.isFundingState());

        _productContract.buy(_account, _amount);
        _projectContract.addEarned(_amount * _productContract.price());
    }
}
