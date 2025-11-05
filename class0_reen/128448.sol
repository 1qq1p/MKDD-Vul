pragma solidity ^0.5.0;


interface TubInterface {
    function wipe(bytes32, uint) external;
    function gov() external view returns (TokenInterface);
    function sai() external view returns (TokenInterface);
    function tab(bytes32) external returns (uint);
    function rap(bytes32) external returns (uint);
    function pep() external view returns (PepInterface);
}

interface TokenInterface {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

interface PepInterface {
    function peek() external returns (bytes32, bool);
}

interface UniswapExchange {
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

    function getSaiTubAddress() public pure returns (address sai) {
        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    }

    function getUniswapMKRExchange() public pure returns (address ume) {
        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;
    }

    function getUniswapDAIExchange() public pure returns (address ude) {
        ude = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    }

    function wipe(
        uint cdpNum,
        uint _wad
    ) public 
    {
        require(_wad > 0, "no-wipe-no-dai");

        TubInterface tub = TubInterface(getSaiTubAddress());
        UniswapExchange daiEx = UniswapExchange(getUniswapDAIExchange());
        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());
        TokenInterface dai = tub.sai();
        TokenInterface mkr = tub.gov();

        bytes32 cup = bytes32(cdpNum);

        setAllowance(dai, getSaiTubAddress());
        setAllowance(mkr, getSaiTubAddress());
        setAllowance(dai, getUniswapDAIExchange());

        (bytes32 val, bool ok) = tub.pep().peek();

        
        uint mkrFee = wdiv(rmul(_wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));

        uint daiAmt = daiEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(mkrFee));
        daiAmt = add(_wad, daiAmt);
        require(dai.transferFrom(msg.sender, address(this), daiAmt), "not-approved-yet");

        if (ok && val != 0) {
            daiEx.tokenToTokenSwapOutput(
                mkrFee,
                daiAmt,
                uint(999000000000000000000),
                uint(1899063809), 
                address(mkr)
            );
        }

        tub.wipe(cup, _wad);
    }

    function setAllowance(TokenInterface token_, address spender_) private {
        if (token_.allowance(address(this), spender_) != uint(-1)) {
            token_.approve(spender_, uint(-1));
        }
    }

}