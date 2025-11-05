pragma solidity ^0.5.2;



interface DutchX {

    function approvedTokens(address)
        external
        view
        returns (bool);

    function getAuctionIndex(
        address token1,
        address token2
    )
        external
        view
        returns (uint auctionIndex);

    function getClearingTime(
        address token1,
        address token2,
        uint auctionIndex
    )
        external
        view
        returns (uint time);

    function getPriceInPastAuction(
        address token1,
        address token2,
        uint auctionIndex
    )
        external
        view
        
        returns (uint num, uint den);
}






contract TokenWhitelist is AuctioneerManaged {
    
    
    
    mapping(address => bool) public approvedTokens;

    event Approval(address indexed token, bool approved);

    
    
    function getApprovedAddressesOfList(address[] calldata addressesToCheck) external view returns (bool[] memory) {
        uint length = addressesToCheck.length;

        bool[] memory isApproved = new bool[](length);

        for (uint i = 0; i < length; i++) {
            isApproved[i] = approvedTokens[addressesToCheck[i]];
        }

        return isApproved;
    }
    
    function updateApprovalOfToken(address[] memory token, bool approved) public onlyAuctioneer {
        for (uint i = 0; i < token.length; i++) {
            approvedTokens[token[i]] = approved;
            emit Approval(token[i], approved);
        }
    }

}




