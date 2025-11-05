pragma solidity ^0.4.8;








contract WavesEthereumSwap is MobileGoToken {
    event WavesTransfer(address indexed _from, string wavesAddress, uint256 amount);

    function moveToWaves(string wavesAddress, uint256 amount) {
        if (!transfer(owner, amount)) throw;
        WavesTransfer(msg.sender, wavesAddress, amount);
    }
}