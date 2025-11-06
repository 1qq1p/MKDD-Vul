pragma solidity ^0.4.17;






contract Presale is CommonSale {

    Mainsale public mainsale;

    function setMainsale(address newMainsale) public onlyOwner {
        mainsale = Mainsale(newMainsale);
    }

    function setMultisigWallet(address newMultisigWallet) public onlyOwner {
        multisigWallet = newMultisigWallet;
    }

    function finishMinting() public whenNotPaused onlyOwner {
        token.setSaleAgent(mainsale);
    }

    function() external payable {
        createTokens();
    }

    function retrieveTokens(address anotherToken) public onlyOwner {
        ERC20 alienToken = ERC20(anotherToken);
        alienToken.transfer(multisigWallet, token.balanceOf(this));
    }

}

