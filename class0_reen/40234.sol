pragma solidity^0.4.21;

contract CDPer is DSStop, DSMath {

    
    
    
    
    
    
    
    

    
    
    uint public slippage = 99*10**16;
    TubInterface public tub = TubInterface(0xa71937147b55Deb8a530C7229C442Fd3F31b7db2);
    DSToken public dai = DSToken(0xC4375B7De8af5a38a93548eb8453a498222C4fF2);  
    DSToken public skr = DSToken(0xf4d791139cE033Ad35DB2B2201435fAd668B1b64);  
    DSToken public gov = DSToken(0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD);  
    WETH public gem = WETH(0xd0A1E359811322d97991E03f863a0C30C2cF029C);  
    DSValue public feed = DSValue(0xA944bd4b25C9F186A846fd5668941AA3d3B8425F);  
    OtcInterface public otc = OtcInterface(0x8cf1Cab422A0b6b554077A361f8419cDf122a9F9);

    
    uint public minETH = WAD / 20; 
    uint public minDai = WAD * 50; 

    
    uint public liquidationPriceWad = 320 * WAD;

    
    uint ratio;

    function CDPer() public {

    }

    


    function init() public auth {
        gem.approve(tub, uint(-1));
        skr.approve(tub, uint(-1));
        dai.approve(tub, uint(-1));
        gov.approve(tub, uint(-1));
        
        gem.approve(owner, uint(-1));
        skr.approve(owner, uint(-1));
        dai.approve(owner, uint(-1));
        gov.approve(owner, uint(-1));

        dai.approve(otc, uint(-1));
        gem.approve(otc, uint(-1));

        tubParamUpdate();
    }

    


    function tubParamUpdate() public auth {
        ratio = tub.mat() / 10**9; 
    }

     



    function createAndJoinCDP() public stoppable payable returns(bytes32 id) {

        require(msg.value >= minETH);

        gem.deposit.value(msg.value)();
        
        id = _openAndJoinCDPWETH(msg.value);

        tub.give(id, msg.sender);
    }

    



    function createAndJoinCDPAllDai() public returns(bytes32 id) {
        return createAndJoinCDPDai(dai.balanceOf(msg.sender));
    }

    




    function createAndJoinCDPDai(uint amount) public auth stoppable returns(bytes32 id) {
        require(amount >= minDai);

        uint price = uint(feed.read());

        require(dai.transferFrom(msg.sender, this, amount));

        uint bought = otc.sellAllAmount(dai, amount,
            gem, wmul(WAD - slippage, wdiv(amount, price)));
        
        id = _openAndJoinCDPWETH(bought);
        
        tub.give(id, msg.sender);
    }


    



    function createCDPLeveraged() public auth stoppable payable returns(bytes32 id) {
        require(msg.value >= minETH);

        uint price = uint(feed.read());

        gem.deposit.value(msg.value)();

        id = _openAndJoinCDPWETH(msg.value);

        while(_reinvest(id, price)) {}

        tub.give(id, msg.sender);
    }

    



    function createCDPLeveragedAllDai() public returns(bytes32 id) {
        return createCDPLeveragedDai(dai.balanceOf(msg.sender)); 
    }
    
    



    function createCDPLeveragedDai(uint amount) public auth stoppable returns(bytes32 id) {

        require(amount >= minDai);

        uint price = uint(feed.read());

        require(dai.transferFrom(msg.sender, this, amount));
        uint bought = otc.sellAllAmount(dai, amount,
            gem, wmul(WAD - slippage, wdiv(amount, price)));

        id = _openAndJoinCDPWETH(bought);

        while(_reinvest(id, price)) {}

        tub.give(id, msg.sender);
    }

    




    function shutForETH(uint _id) public auth stoppable {
        bytes32 id = bytes32(_id);
        uint debt = tub.tab(id);
        if (debt > 0) {
            require(dai.transferFrom(msg.sender, this, debt));
        }
        uint ink = tub.ink(id);
        tub.shut(id);
        uint gemBalance = tub.bid(ink);
        tub.exit(ink);

        gem.withdraw(min(gemBalance, gem.balanceOf(this)));
        
        msg.sender.transfer(min(gemBalance, address(this).balance));
    }

    




    function shutForDai(uint _id) public auth stoppable {
        bytes32 id = bytes32(_id);
        uint debt = tub.tab(id);
        if (debt > 0) {
            require(dai.transferFrom(msg.sender, this, debt));
        }
        uint ink = tub.ink(id);
        tub.shut(id);
        uint gemBalance = tub.bid(ink);
        tub.exit(ink);

        uint price = uint(feed.read());

        uint bought = otc.sellAllAmount(gem, min(gemBalance, gem.balanceOf(this)), 
            dai, wmul(WAD - slippage, wmul(gemBalance, price)));
        
        require(dai.transfer(msg.sender, bought));
    }

    



    function giveMeCDP(uint id) public auth {
        tub.give(bytes32(id), msg.sender);
    }

    



    function giveMeToken(DSToken token) public auth {
        token.transfer(msg.sender, token.balanceOf(this));
    }

    


    function giveMeETH() public auth {
        msg.sender.transfer(address(this).balance);
    }

    


    function destroy() public auth {
        require(stopped);
        selfdestruct(msg.sender);
    }

    



    function setSlippage(uint slip) public auth {
        require(slip < WAD);
        slippage = slip;
    }

    



    function setLiqPrice(uint wad) public auth {        
        liquidationPriceWad = wad;
    }

    



    function setMinETH(uint wad) public auth {
        minETH = wad;
    }

    



    function setMinDai(uint wad) public auth {
        minDai = wad;
    }

    function setTub(TubInterface _tub) public auth {
        tub = _tub;
    }

    function setDai(DSToken _dai) public auth {
        dai = _dai;
    }

    function setSkr(DSToken _skr) public auth {
        skr = _skr;
    }
    function setGov(DSToken _gov) public auth {
        gov = _gov;
    }
    function setGem(WETH _gem) public auth {
        gem = _gem;
    }
    function setFeed(DSValue _feed) public auth {
        feed = _feed;
    }
    function setOTC(OtcInterface _otc) public auth {
        otc = _otc;
    }

    function _openAndJoinCDPWETH(uint amount) internal returns(bytes32 id) {
        id = tub.open();

        _joinCDP(id, amount);
    }

    function _joinCDP(bytes32 id, uint amount) internal {

        uint skRate = tub.ask(WAD);
        
        uint valueSkr = wdiv(amount, skRate);

        tub.join(valueSkr); 

        tub.lock(id, min(valueSkr, skr.balanceOf(this)));
    }

    function _reinvest(bytes32 id, uint latestPrice) internal returns(bool ok) {
        
        
        uint debt = tub.tab(id);
        uint ink = tub.ink(id);
        
        uint maxInvest = wdiv(wmul(liquidationPriceWad, ink), ratio);
        
        if(debt >= maxInvest) {
            return false;
        }
        
        uint leftOver = sub(maxInvest, debt);
        
        if(leftOver >= minDai) {
            tub.draw(id, leftOver);

            uint bought = otc.sellAllAmount(dai, min(leftOver, dai.balanceOf(this)),
                gem, wmul(WAD - slippage, wdiv(leftOver, latestPrice)));
            
            _joinCDP(id, bought);

            return true;
        } else {
            return false;
        }
    }

}
