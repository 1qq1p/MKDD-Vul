pragma solidity ^0.4.24;




























contract SuOperation is SuNFT {
    
    event Personalized(uint256 _nftId);

    
    
    
    struct SuSquare {
        
        uint256 version;

        
        
        
        
        
        
        bytes rgbData;

        
        string title;

        
        string href;
    }

    
    
    
    
    
    
    
    SuSquare[10001] public suSquares;

    
    
    
    
    
    
    
    
    
    function personalizeSquare(
        uint256 _squareId,
        bytes _rgbData,
        string _title,
        string _href
    )
        external
        onlyOwnerOf(_squareId)
        payable
    {
        require(bytes(_title).length <= 64);
        require(bytes(_href).length <= 96);
        require(_rgbData.length == 300);
        suSquares[_squareId].version++;
        suSquares[_squareId].rgbData = _rgbData;
        suSquares[_squareId].title = _title;
        suSquares[_squareId].href = _href;
        if (suSquares[_squareId].version > 3) {
            require(msg.value == 10 finney);
        }
        emit Personalized(_squareId);
    }
}




