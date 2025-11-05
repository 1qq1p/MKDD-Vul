pragma solidity 0.4.24;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Assertion Failed");
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Assertion Failed");
        uint256 c = a / b;
        return c;
    }

}

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface AddressRegistry {
    function getAddr(string name) external view returns(address);
}

interface MakerCDP {
    function open() external returns (bytes32 cup);
    function join(uint wad) external; 
    function exit(uint wad) external; 
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function per() external view returns (uint ray);
    function lad(bytes32 cup) external view returns (address);
}

interface PriceInterface {
    function peek() external view returns (bytes32, bool);
}

interface WETHFace {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

interface InstaKyber {
    function executeTrade(
        address src,
        address dest,
        uint srcAmt,
        uint minConversionRate,
        uint maxDestAmt
    ) external payable returns (uint destAmt);

    function getExpectedPrice(
        address src,
        address dest,
        uint srcAmt
    ) external view returns (uint, uint);
}


contract RepayLoan is IssueLoan {

    event WipedDAI(address borrower, uint daiWipe, uint mkrCharged, address wipedBy);
    event UnlockedETH(address borrower, uint ethFree);

    function repay(uint daiWipe, uint ethFree) public payable {
        if (daiWipe > 0) {wipeDAI(daiWipe, msg.sender);}
        if (ethFree > 0) {unlockETH(ethFree);}
    }

    function wipeDAI(uint daiWipe, address borrower) public payable {
        address dai = getAddress("dai");
        address mkr = getAddress("mkr");
        address eth = getAddress("eth");

        IERC20 daiTkn = IERC20(dai);
        IERC20 mkrTkn = IERC20(mkr);

        uint contractMKR = mkrTkn.balanceOf(address(this)); 
        daiTkn.transferFrom(msg.sender, address(this), daiWipe); 
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        loanMaster.wipe(cdps[borrower], daiWipe); 
        uint mkrCharged = contractMKR - mkrTkn.balanceOf(address(this)); 

        
        if (msg.value > 0) { 
            swapETHMKR(
                eth, mkr, mkrCharged, msg.value
            );
        } else { 
            mkrTkn.transferFrom(msg.sender, address(this), mkrCharged); 
        }

        emit WipedDAI(
            borrower, daiWipe, mkrCharged, msg.sender
        );
    }

    function unlockETH(uint ethFree) public {
        require(!freezed, "Operation Disabled");
        uint pethToUnlock = pethPEReth(ethFree);
        MakerCDP loanMaster = MakerCDP(cdpAddr);
        loanMaster.free(cdps[msg.sender], pethToUnlock); 
        loanMaster.exit(pethToUnlock); 
        WETHFace wethTkn = WETHFace(getAddress("weth"));
        wethTkn.withdraw(ethFree); 
        msg.sender.transfer(ethFree);
        emit UnlockedETH(msg.sender, ethFree);
    }

    function swapETHMKR(
        address eth,
        address mkr,
        uint mkrCharged,
        uint ethQty
    ) internal 
    {
        InstaKyber instak = InstaKyber(getAddress("InstaKyber"));
        uint minRate;
        (, minRate) = instak.getExpectedPrice(eth, mkr, ethQty);
        uint mkrBought = instak.executeTrade.value(ethQty)(
            eth, mkr, ethQty, minRate, mkrCharged
        );
        require(mkrCharged == mkrBought, "ETH not sufficient to cover the MKR fees.");
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }

}

