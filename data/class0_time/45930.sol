pragma solidity ^0.4.18;

contract MainContract is BaseContract {
    
    event BuyChestSuccess(uint count);
    
    mapping (address => uint256) public ownershipChestCount;
    
        modifier isMultiplePrice() {
        require((msg.value % 0.1 ether) == 0);
        _;
    }
    
    modifier isMinValue() {
        require(msg.value >= 0.1 ether);
        _;
    }
    
    function addOwnershipChest(address _owner, uint _num) external onlyOwner {
        ownershipChestCount[_owner] += _num;
    }
    
    function getMyChest(address _owner) external view returns(uint) {
        return ownershipChestCount[_owner];
    }
    
    function buyChest() public payable whenNotPaused isMinValue isMultiplePrice {
        transferOnWallet();
        uint tokens = msg.value.div(0.1 ether);
        ownershipChestCount[msg.sender] += tokens;
        BuyChestSuccess(tokens);
    }
    
    
    function getMiningDetail(uint _id) public canMining(_id) whenNotPaused returns(bool) {
        require(assemblIndexToOwner[_id] == msg.sender);
        if (assemblys[_id].startMiningTime + 259200 <= now) {
            if (assemblys[_id].rang == 6) {
                _generateDetail(40);
            } else {
                _generateDetail(28);
            }
            assemblys[_id].startMiningTime = uint64(now);
            assemblys[_id].countMiningDetail++;
            return true;
        }
        return false;
    }
    
    function getAllDetails(address _owner) public view returns(uint[], uint[]) {
        uint[] memory resultIndex = new uint[](ownershipTokenCount[_owner] - (ownershipAssemblyCount[_owner] * 7));
        uint[] memory resultDna = new uint[](ownershipTokenCount[_owner] - (ownershipAssemblyCount[_owner] * 7));
        uint counter = 0;
        for (uint i = 0; i < details.length; i++) {
          if (detailIndexToOwner[i] == _owner && details[i].idParent == 0) {
            resultIndex[counter] = i;
            resultDna[counter] = details[i].dna;
            counter++;
          }
        }
        return (resultIndex, resultDna);
    }
    
    function _generateDetail(uint _randLim) internal {
        uint _dna = randMod(7);
            
        uint256 newDetailId = createDetail(msg.sender, (_dna * 1000 + randMod(_randLim)));
                
        if (_dna == 1) {
            dHead.push(newDetailId);
        } else if (_dna == 2) {
            dHousing.push(newDetailId);
        } else if (_dna == 3) {
            dLeftHand.push(newDetailId);
        } else if (_dna == 4) {
            dRightHand.push(newDetailId);
        } else if (_dna == 5) {
            dPelvic.push(newDetailId);
        } else if (_dna == 6) {
            dLeftLeg.push(newDetailId);
        } else if (_dna == 7) {
            dRightLeg.push(newDetailId);
        }
    }
    
    function init(address _owner, uint _color) external onlyOwner {
        
        uint _dna = 1;
        
        for (uint i = 0; i < 7; i++) {
            
            uint256 newDetailId = createDetail(_owner, (_dna * 1000 + _color));
            
            if (_dna == 1) {
                dHead.push(newDetailId);
            } else if (_dna == 2) {
                dHousing.push(newDetailId);
            } else if (_dna == 3) {
                dLeftHand.push(newDetailId);
            } else if (_dna == 4) {
                dRightHand.push(newDetailId);
            } else if (_dna == 5) {
                dPelvic.push(newDetailId);
            } else if (_dna == 6) {
                dLeftLeg.push(newDetailId);
            } else if (_dna == 7) {
                dRightLeg.push(newDetailId);
            }
            _dna++;
        }
    }
    
    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;
        return (uint(keccak256(now, msg.sender, randNonce)) % _modulus) + 1;
    }
    
    function openChest() public whenNotPaused {
        require(ownershipChestCount[msg.sender] >= 1);
        for (uint i = 0; i < 5; i++) {
            _generateDetail(40);
        }
        ownershipChestCount[msg.sender]--;
    }
    
    function open5Chest() public whenNotPaused {
        require(ownershipChestCount[msg.sender] >= 5);
        for (uint i = 0; i < 5; i++) {
            openChest();
        }
    }
    
    function rechargeRobot(uint _robotId) external whenNotPaused payable {
        require(assemblIndexToOwner[_robotId] == msg.sender &&
                msg.value == costRecharge(_robotId));
        if (assemblys[_robotId].rang == 6) {
            require(assemblys[_robotId].countMiningDetail == (assemblys[_robotId].rang - 1));
        } else {
            require(assemblys[_robotId].countMiningDetail == assemblys[_robotId].rang);
        }   
        transferOnWallet();        
        assemblys[_robotId].countMiningDetail = 0;
        assemblys[_robotId].startMiningTime = 0;
    }
    
    
}