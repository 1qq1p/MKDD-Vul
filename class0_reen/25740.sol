pragma solidity ^0.4.24;








pragma solidity ^0.4.24;

library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  


  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  



  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract LuckyBar is Bank {

    struct record {
        uint[5] date;
        uint[5] amount;
        address[5] account;
    }
    
    struct pair {
        uint256 maxBet;
        uint256 minBet;
        uint256 houseEdge; 
        uint256 reward;
        bool bEnabled;
        record ranking;
        record latest;
    }

    pair public sE2E;
    pair public sE2C;
    pair public sC2E;
    pair public sC2C;

    uint256 public E2C_Ratio;
    uint256 private salt;
    IERC20 private token;
    StandardTokenERC20Custom private chip;
    address public manager;

    
    
    event Won(bool _status, string _rewardType, uint _amount);
    event Swapped(string _target, uint _amount);

    
    constructor() payable public {
        estalishOwnership();
        setProperties("thisissaltIneedtomakearandomnumber", 100000);
        setToken(0x0bfd1945683489253e401485c6bbb2cfaedca313); 
        setChip(0x27a88bfb581d4c68b0fb830ee4a493da94dcc86c); 
        setGameMinBet(100e18, 0.1 ether, 100e18, 0.1 ether);
        setGameMaxBet(10000000e18, 1 ether, 100000e18, 1 ether);
        setGameFee(1,0,5,5);
        enableGame(true, true, false, true);
        setReward(0,5000,0,5000);
        manager = owner;
    }
    
    function getRecordsE2E() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sE2E.ranking.date,sE2E.ranking.amount,sE2E.ranking.account, sE2E.latest.date,sE2E.latest.amount,sE2E.latest.account);
    }
    function getRecordsE2C() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sE2C.ranking.date,sE2C.ranking.amount,sE2C.ranking.account, sE2C.latest.date,sE2C.latest.amount,sE2C.latest.account);
    }
    function getRecordsC2E() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sC2E.ranking.date,sC2E.ranking.amount,sC2E.ranking.account, sC2E.latest.date,sC2E.latest.amount,sC2E.latest.account);
    }
    function getRecordsC2C() public view returns(uint[5], uint[5], address[5],uint[5], uint[5], address[5]) {
        return (sC2C.ranking.date,sC2C.ranking.amount,sC2C.ranking.account, sC2C.latest.date,sC2C.latest.amount,sC2C
        .latest.account);
    }

    function emptyRecordsE2E() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sE2E.ranking.amount[i] = 0;
            sE2E.ranking.date[i] = 0;
            sE2E.ranking.account[i] = 0x0;
            sE2E.latest.amount[i] = 0;
            sE2E.latest.date[i] = 0;
            sE2E.latest.account[i] = 0x0;
        }
    }

    function emptyRecordsE2C() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sE2C.ranking.amount[i] = 0;
            sE2C.ranking.date[i] = 0;
            sE2C.ranking.account[i] = 0x0;
            sE2C.latest.amount[i] = 0;
            sE2C.latest.date[i] = 0;
            sE2C.latest.account[i] = 0x0;
        }
    }

    function emptyRecordsC2E() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sC2E.ranking.amount[i] = 0;
            sC2E.ranking.date[i] = 0;
            sC2E.ranking.account[i] = 0x0;
            sC2E.latest.amount[i] = 0;
            sC2E.latest.date[i] = 0;
            sC2E.latest.account[i] = 0x0;     
        }
    }

    function emptyRecordsC2C() public onlyOwner {
        for(uint i=0;i<5;i++) {
            sC2C.ranking.amount[i] = 0;
            sC2C.ranking.date[i] = 0;
            sC2C.ranking.account[i] = 0x0;
            sC2C.latest.amount[i] = 0;
            sC2C.latest.date[i] = 0;
            sC2C.latest.account[i] = 0x0;
        }
    }


    function setReward(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.reward = C2C;
        sE2C.reward = E2C;
        sC2E.reward = C2E;
        sE2E.reward = E2E;
    }
    
    function enableGame(bool C2C, bool E2C, bool C2E, bool E2E) public onlyOwner {
        sC2C.bEnabled = C2C;
        sE2C.bEnabled = E2C;
        sC2E.bEnabled = C2E;
        sE2E.bEnabled = E2E;
    }

    function setGameFee(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.houseEdge = C2C;
        sE2C.houseEdge = E2C;
        sC2E.houseEdge = C2E;
        sE2E.houseEdge = E2E;
    }
    
    function setGameMaxBet(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.maxBet = C2C;
        sE2C.maxBet = E2C;
        sC2E.maxBet = C2E;
        sE2E.maxBet = E2E;
    }

    function setGameMinBet(uint256 C2C, uint256 E2C, uint256 C2E, uint256 E2E) public onlyOwner {
        sC2C.minBet = C2C;
        sE2C.minBet = E2C;
        sC2E.minBet = C2E;
        sE2E.minBet = E2E;
    }

    function setToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function setChip(address _chip) public onlyOwner {
        chip = StandardTokenERC20Custom(_chip);
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function setProperties(string _salt, uint _E2C_Ratio) public onlyOwner {
        require(_E2C_Ratio > 0);
        salt = uint(keccak256(_salt));
        E2C_Ratio = _E2C_Ratio;
    }

    function() public { 
        revert();
    }

    function swapC2T(address _from, uint256 _value) payable public {
        require(chip.transferFrom(_from, manager, _value));
        require(token.transferFrom(manager, _from, _value));

        emit Swapped("TOKA", _value);
    }

    function swapT2C(address _from, uint256 _value) payable public {
        require(token.transferFrom(_from, manager, _value));
        require(chip.transferFrom(manager, _from, _value));

        emit Swapped("CHIP", _value);
    }

    function playC2C(address _from, uint256 _value) payable public {
        require(sC2C.bEnabled);
        require(_value >= sC2C.minBet && _value <= sC2C.maxBet);
        require(chip.transferFrom(_from, manager, _value));

        uint256 amountWon = _value * (50 + uint256(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sC2C.houseEdge) / 100;
        require(chip.transferFrom(manager, _from, amountWon + _value * sC2C.reward)); 
        
        
        for(uint i=0;i<5;i++) {
            if(sC2C.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sC2C.ranking.amount[j] = sC2C.ranking.amount[j-1];
                    sC2C.ranking.date[j] = sC2C.ranking.date[j-1];
                    sC2C.ranking.account[j] = sC2C.ranking.account[j-1];
                }
                sC2C.ranking.amount[i] = amountWon;
                sC2C.ranking.date[i] = now;
                sC2C.ranking.account[i] = _from;
                break;
            }
        }
        
        for(i=4;i>0;i--) {
            sC2C.latest.amount[i] = sC2C.latest.amount[i-1];
            sC2C.latest.date[i] = sC2C.latest.date[i-1];
            sC2C.latest.account[i] = sC2C.latest.account[i-1];
        }
        sC2C.latest.amount[0] = amountWon;
        sC2C.latest.date[0] = now;
        sC2C.latest.account[0] = _from;

        emit Won(amountWon > _value, "CHIP", amountWon);
    }

    function playC2E(address _from, uint256 _value) payable public {
        require(sC2E.bEnabled);
        require(_value >= sC2E.minBet && _value <= sC2E.maxBet);
        require(chip.transferFrom(_from, manager, _value));

        uint256 amountWon = _value * (50 + uint256(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sC2E.houseEdge) / 100 / E2C_Ratio;
        require(_from.send(amountWon));
        
        
        for(uint i=0;i<5;i++) {
            if(sC2E.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sC2E.ranking.amount[j] = sC2E.ranking.amount[j-1];
                    sC2E.ranking.date[j] = sC2E.ranking.date[j-1];
                    sC2E.ranking.account[j] = sC2E.ranking.account[j-1];
                }
                sC2E.ranking.amount[i] = amountWon;
                sC2E.ranking.date[i] = now;
                sC2E.ranking.account[i] = _from;
                break;
            }
        }
        
        for(i=4;i>0;i--) {
            sC2E.latest.amount[i] = sC2E.latest.amount[i-1];
            sC2E.latest.date[i] = sC2E.latest.date[i-1];
            sC2E.latest.account[i] = sC2E.latest.account[i-1];
        }
        sC2E.latest.amount[0] = amountWon;
        sC2E.latest.date[0] = now;
        sC2E.latest.account[0] = _from;

        emit Won(amountWon > (_value / E2C_Ratio), "ETH", amountWon);
    }

    function playE2E() payable public {
        require(sE2E.bEnabled);
        require(msg.value >= sE2E.minBet && msg.value <= sE2E.maxBet);

        uint amountWon = msg.value * (50 + uint(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sE2E.houseEdge) / 100;
        require(msg.sender.send(amountWon));
        require(chip.transferFrom(manager, msg.sender, msg.value * sE2E.reward)); 

        
        for(uint i=0;i<5;i++) {
            if(sE2E.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sE2E.ranking.amount[j] = sE2E.ranking.amount[j-1];
                    sE2E.ranking.date[j] = sE2E.ranking.date[j-1];
                    sE2E.ranking.account[j] = sE2E.ranking.account[j-1];
                }
                sE2E.ranking.amount[i] = amountWon;
                sE2E.ranking.date[i] = now;
                sE2E.ranking.account[i] = msg.sender;
                break;
            }
        }
        
        for(i=4;i>0;i--) {
            sE2E.latest.amount[i] = sE2E.latest.amount[i-1];
            sE2E.latest.date[i] = sE2E.latest.date[i-1];
            sE2E.latest.account[i] = sE2E.latest.account[i-1];
        }
        sE2E.latest.amount[0] = amountWon;
        sE2E.latest.date[0] = now;
        sE2E.latest.account[0] = msg.sender;

        emit Won(amountWon > msg.value, "ETH", amountWon);
    }

    function playE2C() payable public {
        require(sE2C.bEnabled);
        require(msg.value >= sE2C.minBet && msg.value <= sE2C.maxBet);

        uint amountWon = msg.value * (50 + uint(keccak256(block.timestamp, block.difficulty, salt++)) % 100 - sE2C.houseEdge) / 100 * E2C_Ratio;
        require(chip.transferFrom(manager, msg.sender, amountWon));
        require(chip.transferFrom(manager, msg.sender, msg.value * sE2C.reward)); 
        
        
        for(uint i=0;i<5;i++) {
            if(sE2C.ranking.amount[i] < amountWon) {
                for(uint j=4;j>i;j--) {
                    sE2C.ranking.amount[j] = sE2C.ranking.amount[j-1];
                    sE2C.ranking.date[j] = sE2C.ranking.date[j-1];
                    sE2C.ranking.account[j] = sE2C.ranking.account[j-1];
                }
                sE2C.ranking.amount[i] = amountWon;
                sE2C.ranking.date[i] = now;
                sE2C.ranking.account[i] = msg.sender;
                break;
            }
        }
        
        for(i=4;i>0;i--) {
            sE2C.latest.amount[i] = sE2C.latest.amount[i-1];
            sE2C.latest.date[i] = sE2C.latest.date[i-1];
            sE2C.latest.account[i] = sE2C.latest.account[i-1];
        }
        sE2C.latest.amount[0] = amountWon;
        sE2C.latest.date[0] = now;
        sE2C.latest.account[0] = msg.sender;

        emit Won(amountWon > (msg.value * E2C_Ratio), "CHIP", amountWon);
    }

    
    function checkContractBalance() onlyOwner public view returns(uint) {
        return address(this).balance;
    }
    function checkContractBalanceToka() onlyOwner public view returns(uint) {
        return token.balanceOf(manager);
    }
    function checkContractBalanceChip() onlyOwner public view returns(uint) {
        return chip.balanceOf(manager);
    }
}