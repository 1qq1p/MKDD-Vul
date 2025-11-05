

















pragma solidity 0.4.24;


contract MultiAssetProxy is
    MixinAssetProxyDispatcher,
    MixinAuthorizable
{
    
    bytes4 constant internal PROXY_ID = bytes4(keccak256("MultiAsset(uint256[],bytes[])"));

    
    function ()
        external
    {
        
        
        
        assembly {
            
            let selector := and(calldataload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)

            
            
            
            
            
            
            if eq(selector, 0xa85e59e400000000000000000000000000000000000000000000000000000000) {

                
                
                mstore(0, caller)
                mstore(32, authorized_slot)

                
                if iszero(sload(keccak256(0, 64))) {
                    
                    mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                    mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                    mstore(64, 0x0000001553454e4445525f4e4f545f415554484f52495a454400000000000000)
                    mstore(96, 0)
                    revert(0, 100)
                }

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                

                
                let assetDataOffset := calldataload(4)

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                

                
                
                
                
                
                let amountsOffset := calldataload(add(assetDataOffset, 40))

                
                
                
                
                
                
                let nestedAssetDataOffset := calldataload(add(assetDataOffset, 72))

                
                
                
                
                
                
                
                let amountsContentsStart := add(assetDataOffset, add(amountsOffset, 72))

                
                let amountsLen := calldataload(sub(amountsContentsStart, 32))

                
                
                
                
                
                
                
                let nestedAssetDataContentsStart := add(assetDataOffset, add(nestedAssetDataOffset, 72))

                
                let nestedAssetDataLen := calldataload(sub(nestedAssetDataContentsStart, 32))

                
                if sub(amountsLen, nestedAssetDataLen) {
                    
                    mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                    mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                    mstore(64, 0x0000000f4c454e4754485f4d49534d4154434800000000000000000000000000)
                    mstore(96, 0)
                    revert(0, 100)
                }

                
                calldatacopy(
                    0,   
                    0,   
                    100  
                )

                
                mstore(4, 128)
                
                
                let amount := calldataload(100)
        
                
                let amountsByteLen := mul(amountsLen, 32)

                
                let assetProxyId := 0
                let assetProxy := 0

                
                for {let i := 0} lt(i, amountsByteLen) {i := add(i, 32)} {

                    
                    let amountsElement := calldataload(add(amountsContentsStart, i))
                    let totalAmount := mul(amountsElement, amount)

                    
                    if iszero(or(
                        iszero(amount),
                        eq(div(totalAmount, amount), amountsElement)
                    )) {
                        
                        mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                        mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                        mstore(64, 0x0000001055494e543235365f4f564552464c4f57000000000000000000000000)
                        mstore(96, 0)
                        revert(0, 100)
                    }

                    
                    mstore(100, totalAmount)

                    
                    let nestedAssetDataElementOffset := calldataload(add(nestedAssetDataContentsStart, i))

                    
                    
                    
                    
                    
                    
                    
                    
                    
                    let nestedAssetDataElementContentsStart := add(assetDataOffset, add(nestedAssetDataOffset, add(nestedAssetDataElementOffset, 104)))

                    
                    let nestedAssetDataElementLenStart := sub(nestedAssetDataElementContentsStart, 32)
                    let nestedAssetDataElementLen := calldataload(nestedAssetDataElementLenStart)

                    
                    if lt(nestedAssetDataElementLen, 4) {
                        
                        mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                        mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                        mstore(64, 0x0000001e4c454e4754485f475245415445525f5448414e5f335f524551554952)
                        mstore(96, 0x4544000000000000000000000000000000000000000000000000000000000000)
                        revert(0, 100)
                    }

                    
                    let currentAssetProxyId := and(
                        calldataload(nestedAssetDataElementContentsStart),
                        0xffffffff00000000000000000000000000000000000000000000000000000000
                    )

                    
                    
                    if sub(currentAssetProxyId, assetProxyId) {
                        
                        assetProxyId := currentAssetProxyId
                        
                        
                        mstore(132, assetProxyId)
                        mstore(164, assetProxies_slot)
                        assetProxy := sload(keccak256(132, 64))
                    }
                    
                    
                    if iszero(assetProxy) {
                        
                        mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                        mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)
                        mstore(64, 0x0000001a41535345545f50524f58595f444f45535f4e4f545f45584953540000)
                        mstore(96, 0)
                        revert(0, 100)
                    }
    
                    
                    calldatacopy(
                        132,                                
                        nestedAssetDataElementLenStart,     
                        add(nestedAssetDataElementLen, 32)  
                    )

                    
                    let success := call(
                        gas,                                    
                        assetProxy,                             
                        0,                                      
                        0,                                      
                        add(164, nestedAssetDataElementLen),    
                        0,                                      
                        0                                       
                    )

                    
                    if iszero(success) {
                        returndatacopy(
                            0,                
                            0,                
                            returndatasize()  
                        )
                        revert(0, returndatasize())
                    }
                }

                
                return(0, 0)
            }

            
            revert(0, 0)
        }
    }

    
    
    function getProxyId()
        external
        pure
        returns (bytes4)
    {
        return PROXY_ID;
    }
}