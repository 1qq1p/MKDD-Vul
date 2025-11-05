


pragma solidity 0.4.23;


contract VOLUM is AssetProxy {
    function change(string _symbol, string _name) public onlyAssetOwner() returns(bool) {
        if (etoken2.isLocked(etoken2Symbol)) {
            return false;
        }
        name = _name;
        symbol = _symbol;
        return true;
    }
}
