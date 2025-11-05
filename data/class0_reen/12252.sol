pragma solidity ^0.4.16;







contract LockUtils {
    
    address advance_mining = 0x5EDBe36c4c4a816f150959B445d5Ae1F33054a82;
    
    address community = 0xacF2e917E296547C0C476fDACf957111ca0307ce;
    
    address foundation_investment = 0x9746079BEbcFfFf177818e23AedeC834ad0fb5f9;
    
    address mining = 0xBB7d6f428E77f98069AE1E01964A9Ed6db3c5Fe5;
    
    address adviser = 0x0aE269Ae5F511786Fce5938c141DbF42e8A71E12;
    
    uint256 unlock_time_0910 = 1536508800;
    
    uint256 unlock_time_1010 = 1539100800;
    
    uint256 unlock_time_1110 = 1541779200;
    
    uint256 unlock_time_1210 = 1544371200;
    
    uint256 unlock_time_0110 = 1547049600;
    
    uint256 unlock_time_0210 = 1549728000;
    
    uint256 unlock_time_0310 = 1552147200;
    
    uint256 unlock_time_0410 = 1554825600;
    
    uint256 unlock_time_0510 = 1557417600;
    
    uint256 unlock_time_0610 = 1560096000;
    
    uint256 unlock_time_0710 = 1562688000;
    
    uint256 unlock_time_0810 = 1565366400;
    
    uint256 unlock_time_end  = 1568044800;
    
    uint256 time_months = 2678400;
    
    function getLockBalance(address account, uint8 decimals) internal view returns (uint256) {
        uint256 tempLock = 0;
        if (account == advance_mining) {
            if (now < unlock_time_0910) {
                tempLock = 735000000 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0910 && now < unlock_time_1210) {
                tempLock = 367500000 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1210 && now < unlock_time_0310) {
                tempLock = 183750000 * 10 ** uint256(decimals);
            }
        } else if (account == community) {
            if (now < unlock_time_0910) {
                tempLock = 18375000 * 6 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0910 && now < unlock_time_1010) {
                tempLock = 18375000 * 5 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1010 && now < unlock_time_1110) {
                tempLock = 18375000 * 4 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1110 && now < unlock_time_1210) {
                tempLock = 18375000 * 3 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1210 && now < unlock_time_0110) {
                tempLock = 18375000 * 2 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0110 && now < unlock_time_0210) {
                tempLock = 18375000 * 1 * 10 ** uint256(decimals);
            }
        } else if (account == foundation_investment) {
            if (now < unlock_time_0910) {
                tempLock = 18812500 * 12 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0910 && now < unlock_time_1010) {
                tempLock = 18812500 * 11 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1010 && now < unlock_time_1110) {
                tempLock = 18812500 * 10 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1110 && now < unlock_time_1210) {
                tempLock = 18812500 * 9 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1210 && now < unlock_time_0110) {
                tempLock = 18812500 * 8 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0110 && now < unlock_time_0210) {
                tempLock = 18812500 * 7 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0210 && now < unlock_time_0310) {
                tempLock = 18812500 * 6 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0310 && now < unlock_time_0410) {
                tempLock = 18812500 * 5 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0410 && now < unlock_time_0510) {
                tempLock = 18812500 * 4 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0510 && now < unlock_time_0610) {
                tempLock = 18812500 * 3 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0610 && now < unlock_time_0710) {
                tempLock = 18812500 * 2 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0710 && now < unlock_time_0810) {
                tempLock = 18812500 * 1 * 10 ** uint256(decimals);
            }
        } else if (account == mining) {
            if (now < unlock_time_0910) {
                tempLock = 840000000 * 10 ** uint256(decimals);
            }
        } else if (account == adviser) {
            if (now < unlock_time_0910) {
                tempLock = 15750000 * 12 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0910 && now < unlock_time_1010) {
                tempLock = 15750000 * 11 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1010 && now < unlock_time_1110) {
                tempLock = 15750000 * 10 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1110 && now < unlock_time_1210) {
                tempLock = 15750000 * 9 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_1210 && now < unlock_time_0110) {
                tempLock = 15750000 * 8 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0110 && now < unlock_time_0210) {
                tempLock = 15750000 * 7 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0210 && now < unlock_time_0310) {
                tempLock = 15750000 * 6 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0310 && now < unlock_time_0410) {
                tempLock = 15750000 * 5 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0410 && now < unlock_time_0510) {
                tempLock = 15750000 * 4 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0510 && now < unlock_time_0610) {
                tempLock = 15750000 * 3 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0610 && now < unlock_time_0710) {
                tempLock = 15750000 * 2 * 10 ** uint256(decimals);
            } else if (now >= unlock_time_0710 && now < unlock_time_0810) {
                tempLock = 15750000 * 1 * 10 ** uint256(decimals);
            }
        }
        return tempLock;
    }
}
