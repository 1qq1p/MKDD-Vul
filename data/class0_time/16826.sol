pragma solidity 0.4.24;

contract PresalePackTwo is CardPackTwo, Pausable {

    CappedVault public vault;

    Purchase[] purchases;

    struct Purchase {
        uint16 current;
        uint16 count;
        address user;
        uint randomness;
        uint64 commit;
    }

    event PacksPurchased(uint indexed id, address indexed user, uint16 count);
    event PackOpened(uint indexed id, uint16 startIndex, address indexed user, uint[] cardIDs);
    event RandomnessReceived(uint indexed id, address indexed user, uint16 count, uint randomness);

    constructor(CardIntegration integration, CappedVault _vault) public payable CardPackTwo(integration) {
        vault = _vault;
    }

    function basePrice() public returns (uint);
    function getCardDetails(uint16 packIndex, uint8 cardIndex, uint result) public view returns (uint16 proto, uint16 purity);
    
    function packSize() public view returns (uint8) {
        return 5;
    }

    function packsPerClaim() public view returns (uint16) {
        return 15;
    }

    
    function extract(uint num, uint length, uint start) internal pure returns (uint) {
        return (((1 << (length * 8)) - 1) & (num >> ((start * 8) - 1)));
    }

    function purchase(uint16 packCount, address referrer) whenNotPaused public payable {

        require(packCount > 0);
        require(referrer != msg.sender);

        uint price = calculatePrice(basePrice(), packCount);

        require(msg.value >= price);

        Purchase memory p = Purchase({
            user: msg.sender,
            count: packCount,
            commit: uint64(block.number),
            randomness: 0,
            current: 0
        });

        uint id = purchases.push(p) - 1;

        emit PacksPurchased(id, msg.sender, packCount);

        if (referrer != address(0)) {
            uint commission = price / 10;
            referrer.transfer(commission);
            price -= commission;
            emit Referral(referrer, commission, msg.sender);
        }
        
        address(vault).transfer(price); 
    }

    
    
    
    function callback(uint id) public {

        Purchase storage p = purchases[id];

        require(p.randomness == 0);

        bytes32 bhash = blockhash(p.commit);
        
        
        uint random = uint(keccak256(abi.encodePacked(bhash, p.user, address(this), p.count)));

        
        require(uint64(block.number) != p.commit);

        if (uint(bhash) == 0) {
            
            
            
            p.randomness = 1;
        } else {
            p.randomness = random;
        }

        emit RandomnessReceived(id, p.user, p.count, p.randomness);
    }

    

    function claim(uint id) public {
        
        Purchase storage p = purchases[id];

        require(canClaim);

        uint16 proto;
        uint16 purity;
        uint16 count = p.count;
        uint result = p.randomness;
        uint8 size = packSize();

        address user = p.user;
        uint16 current = p.current;

        require(result != 0); 
        
        require(count > 0);

        uint[] memory ids = new uint[](size);

        uint16 end = current + packsPerClaim() > count ? count : current + packsPerClaim();

        require(end > current);

        for (uint16 i = current; i < end; i++) {
            for (uint8 j = 0; j < size; j++) {
                (proto, purity) = getCardDetails(i, j, result);
                ids[j] = integration.createCard(user, proto, purity);
            }
            emit PackOpened(id, (i * size), user, ids);
        }
        p.current += (end - current);
    }

    function predictPacks(uint id) external view returns (uint16[] protos, uint16[] purities) {

        Purchase memory p = purchases[id];

        uint16 proto;
        uint16 purity;
        uint16 count = p.count;
        uint result = p.randomness;
        uint8 size = packSize();

        purities = new uint16[](size * count);
        protos = new uint16[](size * count);

        for (uint16 i = 0; i < count; i++) {
            for (uint8 j = 0; j < size; j++) {
                (proto, purity) = getCardDetails(i, j, result);
                purities[(i * size) + j] = purity;
                protos[(i * size) + j] = proto;
            }
        }
        return (protos, purities);
    }

    function calculatePrice(uint base, uint16 packCount) public view returns (uint) {
        
        uint difference = block.number - creationBlock;
        uint numDays = difference / 6000;
        if (20 > numDays) {
            return (base - (((20 - numDays) * base) / 100)) * packCount;
        }
        return base * packCount;
    }

    function _getCommonPlusRarity(uint32 rand) internal pure returns (CardProto.Rarity) {
        if (rand == 999999) {
            return CardProto.Rarity.Mythic;
        } else if (rand >= 998345) {
            return CardProto.Rarity.Legendary;
        } else if (rand >= 986765) {
            return CardProto.Rarity.Epic;
        } else if (rand >= 924890) {
            return CardProto.Rarity.Rare;
        } else {
            return CardProto.Rarity.Common;
        }
    }

    function _getRarePlusRarity(uint32 rand) internal pure returns (CardProto.Rarity) {
        if (rand == 999999) {
            return CardProto.Rarity.Mythic;
        } else if (rand >= 981615) {
            return CardProto.Rarity.Legendary;
        } else if (rand >= 852940) {
            return CardProto.Rarity.Epic;
        } else {
            return CardProto.Rarity.Rare;
        } 
    }

    function _getEpicPlusRarity(uint32 rand) internal pure returns (CardProto.Rarity) {
        if (rand == 999999) {
            return CardProto.Rarity.Mythic;
        } else if (rand >= 981615) {
            return CardProto.Rarity.Legendary;
        } else {
            return CardProto.Rarity.Epic;
        }
    }

    function _getLegendaryPlusRarity(uint32 rand) internal pure returns (CardProto.Rarity) {
        if (rand == 999999) {
            return CardProto.Rarity.Mythic;
        } else {
            return CardProto.Rarity.Legendary;
        } 
    }

    bool public canClaim = true;

    function setCanClaim(bool claim) public onlyOwner {
        canClaim = claim;
    }

    function getComponents(
        uint16 i, uint8 j, uint rand
    ) internal returns (
        uint random, uint32 rarityRandom, uint16 purityOne, uint16 purityTwo, uint16 protoRandom
    ) {
        random = uint(keccak256(abi.encodePacked(i, rand, j)));
        rarityRandom = uint32(extract(random, 4, 10) % 1000000);
        purityOne = uint16(extract(random, 2, 4) % 1000);
        purityTwo = uint16(extract(random, 2, 6) % 1000);
        protoRandom = uint16(extract(random, 2, 8) % (2**16-1));
        return (random, rarityRandom, purityOne, purityTwo, protoRandom);
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

}
