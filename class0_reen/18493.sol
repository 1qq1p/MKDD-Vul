pragma solidity ^0.4.21;


library strings {
    
    struct slice {
        uint _len;
        uint _ptr;
    }

    




    function toSlice(string self) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    
    function concat(slice self, slice other) internal returns (string) {
        var ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    





    function count(slice self, slice needle) internal returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    
    
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
        uint ptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                
                assembly {
                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
                    let needledata := and(mload(needleptr), mask)
                    let end := add(selfptr, sub(selflen, needlelen))
                    ptr := selfptr
                    loop:
                    jumpi(exit, eq(and(mload(ptr), mask), needledata))
                    ptr := add(ptr, 1)
                    jumpi(loop, lt(sub(ptr, 1), end))
                    ptr := add(selfptr, selflen)
                    exit:
                }
                return ptr;
            } else {
                
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr;
                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    









    function split(slice self, slice needle, slice token) internal returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

     








    function split(slice self, slice needle) internal returns (slice token) {
        split(self, needle, token);
    }

    




    function toString(slice self) internal pure returns (string) {
        var ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

}





contract CSCResourceFactory is OperationalControl, StringHelpers {

    event CSCResourceCreated(string resourceContract, address contractAddress, uint256 amount); 

    mapping(uint16 => address) public resourceIdToAddress; 
    mapping(bytes32 => address) public resourceNameToAddress; 
    mapping(uint16 => bytes32) public resourceIdToName; 

    uint16 resourceTypeCount;

    function CSCResourceFactory() public {
        managerPrimary = msg.sender;
        managerSecondary = msg.sender;
        bankManager = msg.sender;

    }

    function createNewCSCResource(string _name, string _symbol, uint _initialSupply) public anyOperator {

        require(resourceNameToAddress[stringToBytes32(_name)] == 0x0);

        address resourceContract = new CSCResource(_name, _symbol, _initialSupply);

        
        resourceIdToAddress[resourceTypeCount] = resourceContract;
        resourceNameToAddress[stringToBytes32(_name)] = resourceContract;
        resourceIdToName[resourceTypeCount] = stringToBytes32(_name);
        
        emit CSCResourceCreated(_name, resourceContract, _initialSupply);

        
        resourceTypeCount += 1;

    }

    function setResourcesPrimaryManager(address _op) public onlyManager {
        
        require(_op != address(0));

        uint16 totalResources = getResourceCount();

        for(uint16 i = 0; i < totalResources; i++) {
            CSCResource resContract = CSCResource(resourceIdToAddress[i]);
            resContract.setPrimaryManager(_op);
        }

    }

    function setResourcesSecondaryManager(address _op) public onlyManager {

        require(_op != address(0));

        uint16 totalResources = getResourceCount();

        for(uint16 i = 0; i < totalResources; i++) {
            CSCResource resContract = CSCResource(resourceIdToAddress[i]);
            resContract.setSecondaryManager(_op);
        }

    }

    function setResourcesBanker(address _op) public onlyManager {

        require(_op != address(0));

        uint16 totalResources = getResourceCount();

        for(uint16 i = 0; i < totalResources; i++) {
            CSCResource resContract = CSCResource(resourceIdToAddress[i]);
            resContract.setBanker(_op);
        }

    }

    function setResourcesOtherManager(address _op, uint8 _state) public anyOperator {

        require(_op != address(0));

        uint16 totalResources = getResourceCount();

        for(uint16 i = 0; i < totalResources; i++) {
            CSCResource resContract = CSCResource(resourceIdToAddress[i]);
            resContract.setOtherManager(_op, _state);
        }

    }

    function withdrawFactoryResourceBalance(uint16 _resId) public onlyBanker {

        require(resourceIdToAddress[_resId] != 0);

        CSCResource resContract = CSCResource(resourceIdToAddress[_resId]);
        uint256 resBalance = resContract.balanceOf(this);
        resContract.transfer(bankManager, resBalance);

    }

    function transferFactoryResourceAmount(uint16 _resId, address _to, uint256 _amount) public onlyBanker {

        require(resourceIdToAddress[_resId] != 0);
        require(_to != address(0));

        CSCResource resContract = CSCResource(resourceIdToAddress[_resId]);
        uint256 resBalance = resContract.balanceOf(this);
        require(resBalance >= _amount);

        resContract.transfer(_to, _amount);
    }

    function mintResource(uint16 _resId, uint256 _amount) public onlyBanker {

        require(resourceIdToAddress[_resId] != 0);
        CSCResource resContract = CSCResource(resourceIdToAddress[_resId]);
        resContract.mint(this, _amount);
    }

    function burnResource(uint16 _resId, uint256 _amount) public onlyBanker {

        require(resourceIdToAddress[_resId] != 0);
        CSCResource resContract = CSCResource(resourceIdToAddress[_resId]);
        resContract.burn(_amount);
    }

    function getResourceName(uint16 _resId) public view returns (bytes32 name) {
        return resourceIdToName[_resId];
    }

    function getResourceCount() public view returns (uint16 resourceTotal) {
        return resourceTypeCount;
    }

    function getResourceBalance(uint16 _resId, address _wallet) public view returns (uint256 amt) {

        require(resourceIdToAddress[_resId] != 0);

        CSCResource resContract = CSCResource(resourceIdToAddress[_resId]);
        return resContract.balanceOf(_wallet);

    }

    



    function getWalletResourceBalance(address _wallet) external view returns(uint256[] resourceBalance){
        require(_wallet != address(0));
        
        uint16 totalResources = getResourceCount();
        
        uint256[] memory result = new uint256[](totalResources);
        
        for(uint16 i = 0; i < totalResources; i++) {
            CSCResource resContract = CSCResource(resourceIdToAddress[i]);
            result[i] = resContract.balanceOf(_wallet);
        }
        
        return result;
    }

}