pragma solidity ^0.4.11;

interface CommonWallet {
    function receive() external payable;
}

library StringUtils {
    function concat(string _a, string _b)
        internal
        pure
        returns (string)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);

        bytes memory bab = new bytes(_ba.length + _bb.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }
}

library UintStringUtils {
    function toString(uint i)
        internal
        pure
        returns (string)
    {
        if (i == 0) return '0';
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}



library AddressUtils {
    
    
    
    
    
    function isContract(address addr)
        internal
        view
        returns(bool)
    {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

 
 
library SafeMath256 {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }


  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }


  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

library SafeMath32 {
  
  function mul(uint32 a, uint32 b) internal pure returns (uint32 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }


  
  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    
    
    
    return a / b;
  }


  
  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }


  
  function add(uint32 a, uint32 b) internal pure returns (uint32 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

library SafeMath8 {
  
  function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }


  
  function div(uint8 a, uint8 b) internal pure returns (uint8) {
    
    
    
    return a / b;
  }


  
  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    assert(b <= a);
    return a - b;
  }


  
  function add(uint8 a, uint8 b) internal pure returns (uint8 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract EtherDragonsCore is DragonOwnership 
{
    using SafeMath8 for uint8;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;
    using AddressUtils for address;
    using StringUtils for string;
    using UintStringUtils for uint;

    
    address constant NA = address(0);

    
    uint256 public constant BOUNTY_LIMIT = 2500;
    
    uint256 public constant PRESALE_LIMIT = 7500;
    
    uint256 public constant GEN0_CREATION_LIMIT = 90000;
    
    
    uint256 internal presaleCount_;  
    
    uint256 internal bountyCount_;
   
    
    address internal bank_;

    

    
    
    function ()
        public payable
    {
        revert();
    }

    
    
    function getBalance() 
        public view returns (uint256)
    {
        return address(this).balance;
    }    

    
    
    constructor(
        address _bank
    )
        public
    {
        require(_bank != NA);
        
        controller_ = msg.sender;
        bank_ = _bank;
        
        
        name_ = "EtherDragons";
        symbol_ = "ED";
        url_ = "https://game.etherdragons.world/token/";

        
        maxSupply_ = GEN0_CREATION_LIMIT + BOUNTY_LIMIT + PRESALE_LIMIT;
    }

    
    function totalPresaleCount()
        public view returns(uint256)
    {
        return presaleCount_;
    }    

    
    function totalBountyCount()
        public view returns(uint256)
    {
        return bountyCount_;
    }    
    
    
    
    
    
    function canMint()
        public view returns(bool)
    {
        return (mintCount_ + presaleCount_ + bountyCount_) < maxSupply_;
    }

    
    
    
    function minionAdd(address _to)
        external controllerOnly
    {
        require(minions_[_to] == false, "already_minion");
        
        
        
        _setApprovalForAll(address(this), _to, true);
        
        minions_[_to] = true;
    }

    
    
    function minionRemove(address _to)
        external controllerOnly
    {
        require(minions_[_to], "not_a_minion");

        
        _setApprovalForAll(address(this), _to, false);
        minions_[_to] = false;
    }

    
    
    
    function depositTo()
        public payable
    {
        emit Deposit(msg.sender, msg.value);
    }    
    
    
    
    
    
    
    function transferAmount(address _to, uint256 _amount, uint256 _transferCost)
        external minionOnly
    {
        require((_amount + _transferCost) <= address(this).balance, "not enough money!");
        _to.transfer(_amount);

        
        
        
        if (_transferCost > 0) {
            msg.sender.transfer(_transferCost);
        }

        emit Withdraw(_to, _amount);
    }        

   
    
    
    
    
    
    
    
    
    
    
    
    function mintRelease(
        address _to,
        uint256 _fee,
        
        
        uint8   _genNum,
        string   _genome,
        uint256 _parentA,
        uint256 _parentB,
        
        
        uint256 _petId,  
        string   _params,
        uint256 _transferCost
    )
        external minionOnly operateModeOnly returns(uint256)
    {
        require(canMint(), "can_mint");
        require(_to != NA, "_to");
        require((_fee + _transferCost) <= address(this).balance, "_fee");
        require(bytes(_params).length != 0, "params_length");
        require(bytes(_genome).length == 77, "genome_length");
        
        
        if (_parentA != 0 && _parentB != 0) {
            require(_parentA != _parentB, "same_parent");
        }
        else if (_parentA == 0 && _parentB != 0) {
            revert("parentA_empty");
        }
        else if (_parentB == 0 && _parentA != 0) {
            revert("parentB_empty");
        }

        uint256 tokenId = _createToken(_to, _genNum, _genome, _parentA, _parentB, _petId, _params);

        require(_checkAndCallSafeTransfer(NA, _to, tokenId, ""), "safe_transfer");

        
        CommonWallet(bank_).receive.value(_fee)();

        emit Transfer(NA, _to, tokenId);

        
        
        
        if (_transferCost > 0) {
            msg.sender.transfer(_transferCost);
        }

        return tokenId;
    }

    
    
    
    
    
    
    function mintPresell(address _to, string _genome)
        external presaleOnly presaleModeOnly returns(uint256)
    {
        require(presaleCount_ < PRESALE_LIMIT, "presale_limit");

        
        uint256 tokenId = _createToken(_to, 0, _genome, 0, 0, 0, "");
        presaleCount_ += 1;

        require(_checkAndCallSafeTransfer(NA, _to, tokenId, ""), "safe_transfer");

        emit Transfer(NA, _to, tokenId);
        
        return tokenId;
    }    
    
    
    
    
    function mintBounty(address _to, string _genome)
        external controllerOnly returns(uint256)
    {
        require(bountyCount_ < BOUNTY_LIMIT, "bounty_limit");

        
        uint256 tokenId = _createToken(_to, 0, _genome, 0, 0, 0, "");
    
        bountyCount_ += 1;
        require(_checkAndCallSafeTransfer(NA, _to, tokenId, ""), "safe_transfer");

        emit Transfer(NA, _to, tokenId);

        return tokenId;
    }        
}