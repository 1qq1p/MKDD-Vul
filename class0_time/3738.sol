pragma solidity ^0.4.18;







contract FreezableMintableToken is FreezableToken, MintableToken {
    







    function mintAndFreeze(address _to, uint _amount, uint64 _until) public onlyOwner {
        bytes32 currentKey = toKey(_to, _until);
        mint(address(keccak256(currentKey)), _amount);

        freeze(_to, _until);
        Freezed(_to, _until, _amount);
    }
}
