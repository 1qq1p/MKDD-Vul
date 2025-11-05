pragma solidity ^0.4.24;




contract ISTO is IModule, Pausable {

    using SafeMath for uint256;

    enum FundraiseType { ETH, POLY }
    FundraiseType public fundraiseType;

    
    uint256 public startTime;
    
    uint256 public endTime;

    




    function verifyInvestment(address _beneficiary, uint256 _fundsAmount) public view returns(bool) {
        return polyToken.allowance(_beneficiary, address(this)) >= _fundsAmount;
    }

    


    function getRaisedEther() public view returns (uint256);

    


    function getRaisedPOLY() public view returns (uint256);

    


    function getNumberInvestors() public view returns (uint256);

    


    function pause() public onlyOwner {
        require(now < endTime);
        super._pause();
    }

    


    function unpause(uint256 _newEndDate) public onlyOwner {
        require(_newEndDate >= endTime);
        super._unpause();
        endTime = _newEndDate;
    }

    



    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0));
        ERC20Basic token = ERC20Basic(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance));
    }

}






