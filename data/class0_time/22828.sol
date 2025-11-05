





































pragma solidity ^0.4.7;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private {
        
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

    




    function toSlice(string self) internal returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    




    function len(bytes32 self) internal returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    






    function toSliceB32(bytes32 self) internal returns (slice ret) {
        
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    




    function copy(slice self) internal returns (slice) {
        return slice(self._len, self._ptr);
    }

    




    function toString(slice self) internal returns (string) {
        var ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    







    function len(slice self) internal returns (uint) {
        
        var ptr = self._ptr - 31;
        var end = ptr + self._len;
        for (uint len = 0; ptr < end; len++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
        return len;
    }

    




    function empty(slice self) internal returns (bool) {
        return self._len == 0;
    }

    








    function compare(slice self, slice other) internal returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        var selfptr = self._ptr;
        var otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                
                uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                var diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    





    function equals(slice self, slice other) internal returns (bool) {
        return compare(self, other) == 0;
    }

    






    function nextRune(slice self, slice rune) internal returns (slice) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint len;
        uint b;
        
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            len = 1;
        } else if(b < 0xE0) {
            len = 2;
        } else if(b < 0xF0) {
            len = 3;
        } else {
            len = 4;
        }

        
        if (len > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += len;
        self._len -= len;
        rune._len = len;
        return rune;
    }

    





    function nextRune(slice self) internal returns (slice ret) {
        nextRune(self, ret);
    }

    




    function ord(slice self) internal returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint len;
        uint div = 2 ** 248;

        
        assembly { word:= mload(mload(add(self, 32))) }
        var b = word / div;
        if (b < 0x80) {
            ret = b;
            len = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            len = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            len = 3;
        } else {
            ret = b & 0x07;
            len = 4;
        }

        
        if (len > self._len) {
            return 0;
        }

        for (uint i = 1; i < len; i++) {
            div = div / 256;
            b = (word / div) & 0xFF;
            if (b & 0xC0 != 0x80) {
                
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    




    function keccak(slice self) internal returns (bytes32 ret) {
        assembly {
            ret := sha3(mload(add(self, 32)), mload(self))
        }
    }

    





    function startsWith(slice self, slice needle) internal returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let len := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(sha3(selfptr, len), sha3(needleptr, len))
        }
        return equal;
    }

    






    function beyond(slice self, slice needle) internal returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let len := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, len), sha3(needleptr, len))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    





    function endsWith(slice self, slice needle) internal returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        var selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let len := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(sha3(selfptr, len), sha3(needleptr, len))
        }

        return equal;
    }

    






    function until(slice self, slice needle) internal returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        var selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let len := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, len), sha3(needleptr, len))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
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

    
    
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                
                assembly {
                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
                    let needledata := and(mload(needleptr), mask)
                    ptr := add(selfptr, sub(selflen, needlelen))
                    loop:
                    jumpi(ret, eq(and(mload(ptr), mask), needledata))
                    ptr := sub(ptr, 1)
                    jumpi(loop, gt(add(ptr, 1), selfptr))
                    ptr := selfptr
                    jump(exit)
                    ret:
                    ptr := add(ptr, needlelen)
                    exit:
                }
                return ptr;
            } else {
                
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    







    function find(slice self, slice needle) internal returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    







    function rfind(slice self, slice needle) internal returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
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

    









    function rsplit(slice self, slice needle, slice token) internal returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    








    function rsplit(slice self, slice needle) internal returns (slice token) {
        rsplit(self, needle, token);
    }

    





    function count(slice self, slice needle) internal returns (uint count) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            count++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    





    function contains(slice self, slice needle) internal returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    






    function concat(slice self, slice other) internal returns (string) {
        var ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    







    function join(slice self, slice[] parts) internal returns (string) {
        if (parts.length == 0)
            return "";

        uint len = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            len += parts[i]._len;

        var ret = new string(len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}











pragma solidity ^0.4.11;


contract FlightDelayPayout is FlightDelayControlledContract, FlightDelayConstants, FlightDelayOraclizeInterface, ConvertLib {

    using strings for *;

    FlightDelayDatabaseInterface FD_DB;
    FlightDelayLedgerInterface FD_LG;
    FlightDelayAccessControllerInterface FD_AC;

    



    function FlightDelayPayout(address _controller) public {
        setController(_controller);
        oraclize_setCustomGasPrice(ORACLIZE_GASPRICE);
    }

    



    


    function setContracts() public onlyController {
        FD_AC = FlightDelayAccessControllerInterface(getContract("FD.AccessController"));
        FD_DB = FlightDelayDatabaseInterface(getContract("FD.Database"));
        FD_LG = FlightDelayLedgerInterface(getContract("FD.Ledger"));

        FD_AC.setPermissionById(101, "FD.Underwrite");
        FD_AC.setPermissionByAddress(101, oraclize_cbAddress());
        FD_AC.setPermissionById(102, "FD.Funder");
        FD_AC.setPermissionById(103, "FD.Owner");
    }

    


    function () public payable {
        require(FD_AC.checkPermission(102, msg.sender));

        
        
    }

    





    function schedulePayoutOraclizeCall(uint _policyId, bytes32 _riskId, uint _oraclizeTime) public {
        require(FD_AC.checkPermission(101, msg.sender));

        var (carrierFlightNumber, departureYearMonthDay,) = FD_DB.getRiskParameters(_riskId);

        string memory oraclizeUrl = strConcat(
            ORACLIZE_STATUS_BASE_URL,
            b32toString(carrierFlightNumber),
            b32toString(departureYearMonthDay),
            ORACLIZE_STATUS_QUERY
        );

        bytes32 queryId = oraclize_query(
            _oraclizeTime,
            "nested",
            oraclizeUrl,
            ORACLIZE_GAS
        );

        FD_DB.createOraclizeCallback(
            queryId,
            _policyId,
            oraclizeState.ForPayout,
            _oraclizeTime
        );

        LogOraclizeCall(_policyId, queryId, oraclizeUrl, _oraclizeTime);
    }

    





    function __callback(bytes32 _queryId, string _result, bytes _proof) public onlyOraclizeOr(getContract('FD.Emergency')) {

        var (policyId, oraclizeTime) = FD_DB.getOraclizeCallback(_queryId);
        LogOraclizeCallback(policyId, _queryId, _result, _proof);

        
        var state = FD_DB.getPolicyState(policyId);
        require(uint8(state) != 5);

        bytes32 riskId = FD_DB.getRiskId(policyId);





        var slResult = _result.toSlice();

        if (bytes(_result).length == 0) { 
            if (FD_DB.checkTime(_queryId, riskId, 180 minutes)) {
                LogPolicyManualPayout(policyId, "No Callback at +120 min");
                return;
            } else {
                schedulePayoutOraclizeCall(policyId, riskId, oraclizeTime + 45 minutes);
            }
        } else {
            
            
            slResult.find("\"".toSlice()).beyond("\"".toSlice());
            slResult.until(slResult.copy().find("\"".toSlice()));
            bytes1 status = bytes(slResult.toString())[0];	
            if (status == "C") {
                
                payOut(policyId, 4, 0);
                return;
            } else if (status == "D") {
                
                payOut(policyId, 5, 0);
                return;
            } else if (status != "L" && status != "A" && status != "C" && status != "D") {
                LogPolicyManualPayout(policyId, "Unprocessable status");
                return;
            }

            
            slResult = _result.toSlice();
            bool arrived = slResult.contains("actualGateArrival".toSlice());

            if (status == "A" || (status == "L" && !arrived)) {
                
                if (FD_DB.checkTime(_queryId, riskId, 180 minutes)) {
                    LogPolicyManualPayout(policyId, "No arrival at +180 min");
                } else {
                    schedulePayoutOraclizeCall(policyId, riskId, oraclizeTime + 45 minutes);
                }
            } else if (status == "L" && arrived) {
                var aG = "\"arrivalGateDelayMinutes\": ".toSlice();
                if (slResult.contains(aG)) {
                    slResult.find(aG).beyond(aG);
                    slResult.until(slResult.copy().find("\"".toSlice()).beyond("\"".toSlice()));
                    
                    slResult.until(slResult.copy().find("\x7D".toSlice()));
                    slResult.until(slResult.copy().find(",".toSlice()));
                    uint delayInMinutes = parseInt(slResult.toString());
                } else {
                    delayInMinutes = 0;
                }

                if (delayInMinutes < 15) {
                    payOut(policyId, 0, 0);
                } else if (delayInMinutes < 30) {
                    payOut(policyId, 1, delayInMinutes);
                } else if (delayInMinutes < 45) {
                    payOut(policyId, 2, delayInMinutes);
                } else {
                    payOut(policyId, 3, delayInMinutes);
                }
            } else { 
                payOut(policyId, 0, 0);
            }
        }
    }

    



    





    function payOut(uint _policyId, uint8 _delay, uint _delayInMinutes)	internal {







        FD_DB.setDelay(_policyId, _delay, _delayInMinutes);

        if (_delay == 0 || WEIGHT_PATTERN[_delay] == 0) {
            FD_DB.setState(
                _policyId,
                policyState.Expired,
                now,
                "Expired - no delay!"
            );
        } else {
            var (customer, weight, premium) = FD_DB.getPolicyData(_policyId);





            if (weight == 0) {
                weight = 20000;
            }

            uint payout = premium * WEIGHT_PATTERN[_delay] * 10000 / weight;
            uint calculatedPayout = payout;

            if (payout > MAX_PAYOUT) {
                payout = MAX_PAYOUT;
            }

            FD_DB.setPayouts(_policyId, calculatedPayout, payout);

            if (!FD_LG.sendFunds(customer, Acc.Payout, payout)) {
                FD_DB.setState(
                    _policyId,
                    policyState.SendFailed,
                    now,
                    "Payout, send failed!"
                );

                FD_DB.setPayouts(_policyId, calculatedPayout, 0);
            } else {
                FD_DB.setState(
                    _policyId,
                    policyState.PaidOut,
                    now,
                    "Payout successful!"
                );
            }
        }
    }

    function setOraclizeGasPrice(uint _gasPrice) external returns (bool _success) {
        require(FD_AC.checkPermission(103, msg.sender));

        oraclize_setCustomGasPrice(_gasPrice);
        _success = true;
    }
}