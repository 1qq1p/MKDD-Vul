





pragma solidity ^0.4.20;



interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}



contract ChestMining is Random, AccessService {
    using SafeMath for uint256;

    event MiningOrderCreated(uint256 indexed index, address indexed miner, uint64 chestCnt);
    event MiningResolved(uint256 indexed index, address indexed miner, uint64 chestCnt);

    struct MiningOrder {
        address miner;      
        uint64 chestCnt;    
        uint64 tmCreate;    
        uint64 tmResolve;   
    }

    
    uint16 maxProtoId;
    
    uint256 constant prizePoolPercent = 80;
    
    address poolContract;
    
    RaceToken public tokenContract;
    
    IDataMining public dataContract;
    
    MiningOrder[] public ordersArray;

    IRaceCoin public raceCoinContract;


    mapping (uint16 => uint256) public protoIdToCount;


    function ChestMining(address _nftAddr, uint16 _maxProtoId) public {
        addrAdmin = msg.sender;
        addrService = msg.sender;
        addrFinance = msg.sender;

        tokenContract = RaceToken(_nftAddr);
        maxProtoId = _maxProtoId;
        
        MiningOrder memory order = MiningOrder(0, 0, 1, 1);
        ordersArray.push(order);
    }

    function() external payable {

    }

    function getOrderCount() external view returns(uint256) {
        return ordersArray.length - 1;
    }

    function setDataMining(address _addr) external onlyAdmin {
        require(_addr != address(0));
        dataContract = IDataMining(_addr);
    }
    
    function setPrizePool(address _addr) external onlyAdmin {
        require(_addr != address(0));
        poolContract = _addr;
        raceCoinContract = IRaceCoin(_addr);
    }

    

    function setMaxProtoId(uint16 _maxProtoId) external onlyAdmin {
        require(_maxProtoId > 0 && _maxProtoId < 10000);
        require(_maxProtoId != maxProtoId);
        maxProtoId = _maxProtoId;
    }

    

    function setFashionSuitCount(uint16 _protoId, uint256 _cnt) external onlyAdmin {
        require(_protoId > 0 && _protoId <= maxProtoId);
        require(_cnt > 0 && _cnt <= 8);
        require(protoIdToCount[_protoId] != _cnt);
        protoIdToCount[_protoId] = _cnt;
    }

    function _getFashionParam(uint256 _seed) internal view returns(uint16[13] attrs) {
        uint256 curSeed = _seed;
        
        uint256 rdm = curSeed % 10000;
        uint16 qtyParam;
        if (rdm < 6900) {
            attrs[1] = 1;
            qtyParam = 0;
        } else if (rdm < 8700) {
            attrs[1] = 2;
            qtyParam = 1;
        } else if (rdm < 9600) {
            attrs[1] = 3;
            qtyParam = 2;
        } else if (rdm < 9900) {
            attrs[1] = 4;
            qtyParam = 4;
        } else {
            attrs[1] = 5;
            qtyParam = 7;
        }

        
        curSeed /= 10000;
        rdm = ((curSeed % 10000) / (9999 / maxProtoId)) + 1;
        attrs[0] = uint16(rdm <= maxProtoId ? rdm : maxProtoId);

        
        curSeed /= 10000;
        uint256 tmpVal = protoIdToCount[attrs[0]];
        if (tmpVal == 0) {
            tmpVal = 8;
        }
        rdm = ((curSeed % 10000) / (9999 / tmpVal)) + 1;
        uint16 pos = uint16(rdm <= tmpVal ? rdm : tmpVal);
        attrs[2] = pos;

        rdm = attrs[0] % 3;

        curSeed /= 10000;
        tmpVal = (curSeed % 10000) % 21 + 90;

        if (rdm == 0) {
            if (pos == 1) {
                attrs[3] = uint16((20 + qtyParam * 20) * tmpVal / 100);              
            } else if (pos == 2) {
                attrs[4] = uint16((100 + qtyParam * 100) * tmpVal / 100);            
            } else if (pos == 3) {
                attrs[5] = uint16((70 + qtyParam * 70) * tmpVal / 100);              
            } else if (pos == 4) {
                attrs[6] = uint16((500 + qtyParam * 500) * tmpVal / 100);            
            } else if (pos == 5) {
                attrs[7] = uint16((4 + qtyParam * 4) * tmpVal / 100);                
            } else if (pos == 6) {
                attrs[8] = uint16((5 + qtyParam * 5) * tmpVal / 100);                
            } else if (pos == 7) {
                attrs[9] = uint16((5 + qtyParam * 5) * tmpVal / 100);                
            } else {
                attrs[10] = uint16((4 + qtyParam * 4) * tmpVal / 100);               
            } 
        } else if (rdm == 1) {
            if (pos == 1) {
                attrs[3] = uint16((19 + qtyParam * 19) * tmpVal / 100);              
            } else if (pos == 2) {
                attrs[4] = uint16((90 + qtyParam * 90) * tmpVal / 100);            
            } else if (pos == 3) {
                attrs[5] = uint16((63 + qtyParam * 63) * tmpVal / 100);              
            } else if (pos == 4) {
                attrs[6] = uint16((450 + qtyParam * 450) * tmpVal / 100);            
            } else if (pos == 5) {
                attrs[7] = uint16((3 + qtyParam * 3) * tmpVal / 100);                
            } else if (pos == 6) {
                attrs[8] = uint16((4 + qtyParam * 4) * tmpVal / 100);                
            } else if (pos == 7) {
                attrs[9] = uint16((4 + qtyParam * 4) * tmpVal / 100);                
            } else {
                attrs[10] = uint16((3 + qtyParam * 3) * tmpVal / 100);               
            } 
        } else {
            if (pos == 1) {
                attrs[3] = uint16((21 + qtyParam * 21) * tmpVal / 100);              
            } else if (pos == 2) {
                attrs[4] = uint16((110 + qtyParam * 110) * tmpVal / 100);            
            } else if (pos == 3) {
                attrs[5] = uint16((77 + qtyParam * 77) * tmpVal / 100);              
            } else if (pos == 4) {
                attrs[6] = uint16((550 + qtyParam * 550) * tmpVal / 100);            
            } else if (pos == 5) {
                attrs[7] = uint16((5 + qtyParam * 5) * tmpVal / 100);                
            } else if (pos == 6) {
                attrs[8] = uint16((6 + qtyParam * 6) * tmpVal / 100);                
            } else if (pos == 7) {
                attrs[9] = uint16((6 + qtyParam * 6) * tmpVal / 100);                
            } else {
                attrs[10] = uint16((5 + qtyParam * 5) * tmpVal / 100);               
            } 
        }
        attrs[11] = 0;
        attrs[12] = 0;
    }

    function _addOrder(address _miner, uint64 _chestCnt) internal {
        uint64 newOrderId = uint64(ordersArray.length);
        ordersArray.length += 1;
        MiningOrder storage order = ordersArray[newOrderId];
        order.miner = _miner;
        order.chestCnt = _chestCnt;
        order.tmCreate = uint64(block.timestamp);

        emit MiningOrderCreated(newOrderId, _miner, _chestCnt);
    }

    function _transferHelper(uint256 ethVal) private {

        uint256 fVal;
        uint256 pVal;
        
        fVal = ethVal.mul(prizePoolPercent).div(100);
        pVal = ethVal.sub(fVal);
        addrFinance.transfer(pVal);
        if (poolContract != address(0) && pVal > 0) {
            poolContract.transfer(fVal);
            raceCoinContract.addTotalEtherPool(fVal);
        }        
        
    }

    function miningOneFree()
        external
        payable
        whenNotPaused
    {
        require(dataContract != address(0));

        uint256 seed = _rand();
        uint16[13] memory attrs = _getFashionParam(seed);

        require(dataContract.subFreeMineral(msg.sender));

        tokenContract.createFashion(msg.sender, attrs, 3);

        emit MiningResolved(0, msg.sender, 1);
    }

    function miningOneSelf() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.01 ether);

        uint256 seed = _rand();
        uint16[13] memory attrs = _getFashionParam(seed);

        tokenContract.createFashion(msg.sender, attrs, 2);
        _transferHelper(0.01 ether);

        if (msg.value > 0.01 ether) {
            msg.sender.transfer(msg.value - 0.01 ether);
        }

        emit MiningResolved(0, msg.sender, 1);
    }


    function miningThreeSelf() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.03 ether);


        for (uint64 i = 0; i < 3; ++i) {
            uint256 seed = _rand();
            uint16[13] memory attrs = _getFashionParam(seed);
            tokenContract.createFashion(msg.sender, attrs, 2);
        }

        _transferHelper(0.03 ether);

        if (msg.value > 0.03 ether) {
            msg.sender.transfer(msg.value - 0.03 ether);
        }

        emit MiningResolved(0, msg.sender, 3);
    }

    function miningFiveSelf() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.0475 ether);


        for (uint64 i = 0; i < 5; ++i) {
            uint256 seed = _rand();
            uint16[13] memory attrs = _getFashionParam(seed);
            tokenContract.createFashion(msg.sender, attrs, 2);
        }

        _transferHelper(0.0475 ether);

        if (msg.value > 0.0475 ether) {
            msg.sender.transfer(msg.value - 0.0475 ether);
        }

        emit MiningResolved(0, msg.sender, 5);
    }


    function miningTenSelf() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.09 ether);


        for (uint64 i = 0; i < 10; ++i) {
            uint256 seed = _rand();
            uint16[13] memory attrs = _getFashionParam(seed);
            tokenContract.createFashion(msg.sender, attrs, 2);
        }

        _transferHelper(0.09 ether);

        if (msg.value > 0.09 ether) {
            msg.sender.transfer(msg.value - 0.09 ether);
        }

        emit MiningResolved(0, msg.sender, 10);
    }
    

    function miningOne() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.01 ether);

        _addOrder(msg.sender, 1);
        _transferHelper(0.01 ether);

        if (msg.value > 0.01 ether) {
            msg.sender.transfer(msg.value - 0.01 ether);
        }
    }

    function miningThree() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.03 ether);

        _addOrder(msg.sender, 3);
        _transferHelper(0.03 ether);

        if (msg.value > 0.03 ether) {
            msg.sender.transfer(msg.value - 0.03 ether);
        }
    }

    function miningFive() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.0475 ether);

        _addOrder(msg.sender, 5);
        _transferHelper(0.0475 ether);

        if (msg.value > 0.0475 ether) {
            msg.sender.transfer(msg.value - 0.0475 ether);
        }
    }

    function miningTen() 
        external 
        payable 
        whenNotPaused
    {
        require(msg.value >= 0.09 ether);
        
        _addOrder(msg.sender, 10);
        _transferHelper(0.09 ether);

        if (msg.value > 0.09 ether) {
            msg.sender.transfer(msg.value - 0.09 ether);
        }
    }

    function miningResolve(uint256 _orderIndex, uint256 _seed) 
        external 
        onlyService
    {
        require(_orderIndex > 0 && _orderIndex < ordersArray.length);
        MiningOrder storage order = ordersArray[_orderIndex];
        require(order.tmResolve == 0);
        address miner = order.miner;
        require(miner != address(0));
        uint64 chestCnt = order.chestCnt;
        require(chestCnt >= 1 && chestCnt <= 10);

        uint256 rdm = _seed;
        uint16[13] memory attrs;
        for (uint64 i = 0; i < chestCnt; ++i) {
            rdm = _randBySeed(rdm);
            attrs = _getFashionParam(rdm);
            tokenContract.createFashion(miner, attrs, 2);
        }
        order.tmResolve = uint64(block.timestamp);
        emit MiningResolved(_orderIndex, miner, chestCnt);
    }
}