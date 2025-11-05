pragma solidity >=0.4.25 <0.6.0;

pragma experimental ABIEncoderV2;














contract RevenueToken is ERC20Mintable {
    using SafeMath for uint256;

    bool public mintingDisabled;

    address[] public holders;

    mapping(address => bool) public holdersMap;

    mapping(address => uint256[]) public balances;

    mapping(address => uint256[]) public balanceBlocks;

    mapping(address => uint256[]) public balanceBlockNumbers;

    event DisableMinting();

    



    function disableMinting()
    public
    onlyMinter
    {
        mintingDisabled = true;

        emit DisableMinting();
    }

    





    function mint(address to, uint256 value)
    public
    onlyMinter
    returns (bool)
    {
        require(!mintingDisabled, "Minting disabled [RevenueToken.sol:60]");

        
        bool minted = super.mint(to, value);

        if (minted) {
            
            addBalanceBlocks(to);

            
            if (!holdersMap[to]) {
                holdersMap[to] = true;
                holders.push(to);
            }
        }

        return minted;
    }

    





    function transfer(address to, uint256 value)
    public
    returns (bool)
    {
        
        bool transferred = super.transfer(to, value);

        if (transferred) {
            
            addBalanceBlocks(msg.sender);
            addBalanceBlocks(to);

            
            if (!holdersMap[to]) {
                holdersMap[to] = true;
                holders.push(to);
            }
        }

        return transferred;
    }

    








    function approve(address spender, uint256 value)
    public
    returns (bool)
    {
        
        require(
            0 == value || 0 == allowance(msg.sender, spender),
            "Value or allowance non-zero [RevenueToken.sol:121]"
        );

        
        return super.approve(spender, value);
    }

    






    function transferFrom(address from, address to, uint256 value)
    public
    returns (bool)
    {
        
        bool transferred = super.transferFrom(from, to, value);

        if (transferred) {
            
            addBalanceBlocks(from);
            addBalanceBlocks(to);

            
            if (!holdersMap[to]) {
                holdersMap[to] = true;
                holders.push(to);
            }
        }

        return transferred;
    }

    








    function balanceBlocksIn(address account, uint256 startBlock, uint256 endBlock)
    public
    view
    returns (uint256)
    {
        require(startBlock < endBlock, "Bounds parameters mismatch [RevenueToken.sol:173]");
        require(account != address(0), "Account is null address [RevenueToken.sol:174]");

        if (balanceBlockNumbers[account].length == 0 || endBlock < balanceBlockNumbers[account][0])
            return 0;

        uint256 i = 0;
        while (i < balanceBlockNumbers[account].length && balanceBlockNumbers[account][i] < startBlock)
            i++;

        uint256 r;
        if (i >= balanceBlockNumbers[account].length)
            r = balances[account][balanceBlockNumbers[account].length - 1].mul(endBlock.sub(startBlock));

        else {
            uint256 l = (i == 0) ? startBlock : balanceBlockNumbers[account][i - 1];

            uint256 h = balanceBlockNumbers[account][i];
            if (h > endBlock)
                h = endBlock;

            h = h.sub(startBlock);
            r = (h == 0) ? 0 : balanceBlocks[account][i].mul(h).div(balanceBlockNumbers[account][i].sub(l));
            i++;

            while (i < balanceBlockNumbers[account].length && balanceBlockNumbers[account][i] < endBlock) {
                r = r.add(balanceBlocks[account][i]);
                i++;
            }

            if (i >= balanceBlockNumbers[account].length)
                r = r.add(
                    balances[account][balanceBlockNumbers[account].length - 1].mul(
                        endBlock.sub(balanceBlockNumbers[account][balanceBlockNumbers[account].length - 1])
                    )
                );

            else if (balanceBlockNumbers[account][i - 1] < endBlock)
                r = r.add(
                    balanceBlocks[account][i].mul(
                        endBlock.sub(balanceBlockNumbers[account][i - 1])
                    ).div(
                        balanceBlockNumbers[account][i].sub(balanceBlockNumbers[account][i - 1])
                    )
                );
        }

        return r;
    }

    



    function balanceUpdatesCount(address account)
    public
    view
    returns (uint256)
    {
        return balanceBlocks[account].length;
    }

    



    function holdersCount()
    public
    view
    returns (uint256)
    {
        return holders.length;
    }

    






    function holdersByIndices(uint256 low, uint256 up, bool posOnly)
    public
    view
    returns (address[] memory)
    {
        require(low <= up, "Bounds parameters mismatch [RevenueToken.sol:259]");

        up = up > holders.length - 1 ? holders.length - 1 : up;

        uint256 length = 0;
        if (posOnly) {
            for (uint256 i = low; i <= up; i++)
                if (0 < balanceOf(holders[i]))
                    length++;
        } else
            length = up - low + 1;

        address[] memory _holders = new address[](length);

        uint256 j = 0;
        for (uint256 i = low; i <= up; i++)
            if (!posOnly || 0 < balanceOf(holders[i]))
                _holders[j++] = holders[i];

        return _holders;
    }

    function addBalanceBlocks(address account)
    private
    {
        uint256 length = balanceBlockNumbers[account].length;
        balances[account].push(balanceOf(account));
        if (0 < length)
            balanceBlocks[account].push(
                balances[account][length - 1].mul(
                    block.number.sub(balanceBlockNumbers[account][length - 1])
                )
            );
        else
            balanceBlocks[account].push(0);
        balanceBlockNumbers[account].push(block.number);
    }
}




library Address {
    






    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}










library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    





    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        

        require(address(token).isContract());

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)));
        }
    }
}



















