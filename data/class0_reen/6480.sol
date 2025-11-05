pragma solidity ^0.4.18;

contract SkinBase is Manager {

    struct Skin {
        uint128 appearance;
        uint64 cooldownEndTime;
        uint64 mixingWithId;
    }

    
    mapping (uint256 => Skin) skins;

    
    mapping (uint256 => address) public skinIdToOwner;

    
    mapping (uint256 => bool) public isOnSale;

    
    mapping (address => uint256) public accountsToActiveSkin;

    
    
    uint256 public nextSkinId = 1;  

    
    mapping (address => uint256) public numSkinOfAccounts;

    event SkinTransfer(address from, address to, uint256 skinId);
    event SetActiveSkin(address account, uint256 skinId);

    
    function skinOfAccountById(address account, uint256 id) external view returns (uint256) {
        uint256 count = 0;
        uint256 numSkinOfAccount = numSkinOfAccounts[account];
        require(numSkinOfAccount > 0);
        require(id < numSkinOfAccount);
        for (uint256 i = 1; i < nextSkinId; i++) {
            if (skinIdToOwner[i] == account) {
                
                if (count == id) {
                    
                    return i;
                } 
                count++;
            }
        }
        revert();
    }

    
    function getSkin(uint256 id) public view returns (uint128, uint64, uint64) {
        require(id > 0);
        require(id < nextSkinId);
        Skin storage skin = skins[id];
        return (skin.appearance, skin.cooldownEndTime, skin.mixingWithId);
    }

    function withdrawETH() external onlyCAO {
        cfo.transfer(address(this).balance);
    }
    
    function transferP2P(uint256 id, address targetAccount) whenTransferAllowed public {
        require(skinIdToOwner[id] == msg.sender);
        require(msg.sender != targetAccount);
        skinIdToOwner[id] = targetAccount;
        
        numSkinOfAccounts[msg.sender] -= 1;
        numSkinOfAccounts[targetAccount] += 1;
        
        
        emit SkinTransfer(msg.sender, targetAccount, id);
    }

    function _isComplete(uint256 id) internal view returns (bool) {
        uint128 _appearance = skins[id].appearance;
        uint128 mask = uint128(65535);
        uint128 _type = _appearance & mask;
        uint128 maskedValue;
        for (uint256 i = 1; i < 8; i++) {
            mask = mask << 16;
            maskedValue = (_appearance & mask) >> (16*i);
            if (maskedValue != _type) {
                return false;
            }
        } 
        return true;
    }

    function setActiveSkin(uint256 id) public {
        require(skinIdToOwner[id] == msg.sender);
        require(_isComplete(id));
        require(isOnSale[id] == false);
        require(skins[id].mixingWithId == 0);

        accountsToActiveSkin[msg.sender] = id;
        emit SetActiveSkin(msg.sender, id);
    }

    function getActiveSkin(address account) public view returns (uint128) {
        uint256 activeId = accountsToActiveSkin[account];
        if (activeId == 0) {
            return uint128(0);
        }
        return (skins[activeId].appearance & uint128(65535));
    }
}

