pragma solidity ^0.5.0;


interface TubLike {
    function wipe(bytes32, uint) external;
    function gov() external view returns (TokenLike);
    function sai() external view returns (TokenLike);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function pep() external view returns (PepLike);
}

interface TokenLike {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface PepLike {
    function peek() external returns (bytes32, bool);
}

interface UniswapExchangeLike {
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address tokenAddr
        ) external returns (uint256  tokensSold);
}


contract WipeProxy is DSMath {

    function wipeWithDai(
        address _tub,
        address _daiEx,
        address _mkrEx,
        uint cupid,
        uint wad
    ) public 
    {
        require(wad > 0, "no-wipe-no-dai");

        TubLike tub = TubLike(_tub);
        UniswapExchangeLike daiEx = UniswapExchangeLike(_daiEx);
        UniswapExchangeLike mkrEx = UniswapExchangeLike(_mkrEx);
        TokenLike dai = tub.sai();
        TokenLike mkr = tub.gov();
        PepLike pep = tub.pep();

        bytes32 cup = bytes32(cupid);

        setAllowance(dai, _tub);
        setAllowance(mkr, _tub);
        setAllowance(dai, _daiEx);

        (bytes32 val, bool ok) = pep.peek();

        
        uint mkrFee = wdiv(rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));

        uint ethAmt = mkrEx.getEthToTokenOutputPrice(mkrFee);
        uint daiAmt = daiEx.getTokenToEthOutputPrice(ethAmt);

        daiAmt = add(wad, daiAmt);
        require(dai.transferFrom(msg.sender, address(this), daiAmt), "not-approved-yet");

        if (ok && val != 0) {
            daiEx.tokenToTokenSwapOutput(
                mkrFee,
                daiAmt,
                uint(999000000000000000000),
                uint(1645118771), 
                address(mkr)
            );
        }

        tub.wipe(cup, wad);
    }

    function setAllowance(TokenLike token_, address spender_) private {
        if (token_.allowance(address(this), spender_) != uint(-1)) {
            token_.approve(spender_, uint(-1));
        }
    }

}