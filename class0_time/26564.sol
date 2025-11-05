

pragma solidity ^0.5.2;


library Dictionary {
    uint private constant NULL = 0;

    struct Node {
        uint prev;
        uint next;
        bytes data;
        bool initialized;
    }

    struct Data {
        mapping(uint => Node) list;
        uint firstNodeId;
        uint lastNodeId;
        uint len;
    }

    function insertAfter(
        Data storage self,
        uint afterId,
        uint id,
        bytes memory data
    ) internal {
        if (self.list[id].initialized) {
            self.list[id].data = data;
            return;
        }
        self.list[id].prev = afterId;
        if (self.list[afterId].next == NULL) {
            self.list[id].next = NULL;
            self.lastNodeId = id;
        } else {
            self.list[id].next = self.list[afterId].next;
            self.list[self.list[afterId].next].prev = id;
        }
        self.list[id].data = data;
        self.list[id].initialized = true;
        self.list[afterId].next = id;
        self.len++;
    }

    function insertBefore(
        Data storage self,
        uint beforeId,
        uint id,
        bytes memory data
    ) internal {
        if (self.list[id].initialized) {
            self.list[id].data = data;
            return;
        }
        self.list[id].next = beforeId;
        if (self.list[beforeId].prev == NULL) {
            self.list[id].prev = NULL;
            self.firstNodeId = id;
        } else {
            self.list[id].prev = self.list[beforeId].prev;
            self.list[self.list[beforeId].prev].next = id;
        }
        self.list[id].data = data;
        self.list[id].initialized = true;
        self.list[beforeId].prev = id;
        self.len++;
    }

    function insertBeginning(Data storage self, uint id, bytes memory data)
        internal
    {
        if (self.list[id].initialized) {
            self.list[id].data = data;
            return;
        }
        if (self.firstNodeId == NULL) {
            self.firstNodeId = id;
            self.lastNodeId = id;
            self.list[id] = Node({
                prev: 0,
                next: 0,
                data: data,
                initialized: true
            });
            self.len++;
        } else insertBefore(self, self.firstNodeId, id, data);
    }

    function insertEnd(Data storage self, uint id, bytes memory data) internal {
        if (self.lastNodeId == NULL) insertBeginning(self, id, data);
        else insertAfter(self, self.lastNodeId, id, data);
    }

    function set(Data storage self, uint id, bytes memory data) internal {
        insertEnd(self, id, data);
    }

    function get(Data storage self, uint id)
        internal
        view
        returns (bytes memory)
    {
        return self.list[id].data;
    }

    function remove(Data storage self, uint id) internal returns (bool) {
        uint nextId = self.list[id].next;
        uint prevId = self.list[id].prev;

        if (prevId == NULL) self.firstNodeId = nextId; 
        else self.list[prevId].next = nextId;

        if (nextId == NULL) self.lastNodeId = prevId; 
        else self.list[nextId].prev = prevId;

        delete self.list[id];
        self.len--;

        return true;
    }

    function getSize(Data storage self) internal view returns (uint) {
        return self.len;
    }

    function next(Data storage self, uint id) internal view returns (uint) {
        return self.list[id].next;
    }

    function prev(Data storage self, uint id) internal view returns (uint) {
        return self.list[id].prev;
    }

    function keys(Data storage self) internal view returns (uint[] memory) {
        uint[] memory arr = new uint[](self.len);
        uint node = self.firstNodeId;
        for (uint i = 0; i < self.len; i++) {
            arr[i] = node;
            node = next(self, node);
        }
        return arr;
    }
}



pragma solidity ^0.5.0;





interface IERC20 {
    


    function totalSupply() external view returns (uint256);

    


    function balanceOf(address account) external view returns (uint256);

    






    function transfer(address recipient, uint256 amount) external returns (bool);

    






    function allowance(address owner, address spender) external view returns (uint256);

    













    function approve(address spender, uint256 amount) external returns (bool);

    








    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    





    event Transfer(address indexed from, address indexed to, uint256 value);

    



    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;














library SafeMath {
    








    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    








    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    








    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    










    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    










    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;








































contract ReverseRegistrar {
    function setName(string memory name) public returns (bytes32);
}
