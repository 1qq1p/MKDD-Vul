pragma solidity ^0.4.21;




































library LinkedListLib {

    uint256 constant NULL = 0;
    uint256 constant HEAD = 0;
    bool constant PREV = false;
    bool constant NEXT = true;
    
    struct LinkedList{
        mapping (uint256 => mapping (bool => uint256)) list;
    }

    
    
    function listExists(LinkedList storage self)
        internal
        view returns (bool)
    {
        
        if (self.list[HEAD][PREV] != HEAD || self.list[HEAD][NEXT] != HEAD) {
            return true;
        } else {
            return false;
        }
    }

    
    
    
    function nodeExists(LinkedList storage self, uint256 _node) 
        internal
        view returns (bool)
    {
        if (self.list[_node][PREV] == HEAD && self.list[_node][NEXT] == HEAD) {
            if (self.list[HEAD][NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }
    
    
    
    function sizeOf(LinkedList storage self) internal view returns (uint256 numElements) {
        bool exists;
        uint256 i;
        (exists,i) = getAdjacent(self, HEAD, NEXT);
        while (i != HEAD) {
            (exists,i) = getAdjacent(self, i, NEXT);
            numElements++;
        }
        return;
    }

    
    
    
    function getNode(LinkedList storage self, uint256 _node)
        internal view returns (bool,uint256,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0,0);
        } else {
            return (true,self.list[_node][PREV], self.list[_node][NEXT]);
        }
    }

    
    
    
    
    function getAdjacent(LinkedList storage self, uint256 _node, bool _direction)
        internal view returns (bool,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0);
        } else {
            return (true,self.list[_node][_direction]);
        }
    }
    
    
    
    
    
    
    
    function getSortedSpot(LinkedList storage self, uint256 _node, uint256 _value, bool _direction)
        internal view returns (uint256)
    {
        if (sizeOf(self) == 0) { return 0; }
        require((_node == 0) || nodeExists(self,_node));
        bool exists;
        uint256 next;
        (exists,next) = getAdjacent(self, _node, _direction);
        while  ((next != 0) && (_value != next) && ((_value < next) != _direction)) next = self.list[next][_direction];
        return next;
    }
    
    
    
    
    
    
    
    function getSortedSpotByFunction(LinkedList storage self, uint256 _node, uint256 _value, bool _direction, function (uint, uint) view returns (bool) smallerComparator, int256 searchLimit)
        internal view returns (uint256 nextNodeIndex, bool found, uint256 sizeEnd)
    {
        if ((sizeEnd=sizeOf(self)) == 0) { return (0, true, sizeEnd); }
        require((_node == 0) || nodeExists(self,_node));
        bool exists;
        uint256 next;
        (exists,next) = getAdjacent(self, _node, _direction);
        while  ((--searchLimit >= 0) && (next != 0) && (_value != next) && (smallerComparator(_value, next) != _direction)) next = self.list[next][_direction];
        if(searchLimit >= 0)
            return (next, true, sizeEnd + 1);
        else return (0, false, sizeEnd); 
    }

    
    
    
    
    function createLink(LinkedList storage self, uint256 _node, uint256 _link, bool _direction) internal  {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

    
    
    
    
    
    function insert(LinkedList storage self, uint256 _node, uint256 _new, bool _direction) internal returns (bool) {
        if(!nodeExists(self,_new) && nodeExists(self,_node)) {
            uint256 c = self.list[_node][_direction];
            createLink(self, _node, _new, _direction);
            createLink(self, _new, c, _direction);
            return true;
        } else {
            return false;
        }
    }
    
    
    
    
    function remove(LinkedList storage self, uint256 _node) internal returns (uint256) {
        if ((_node == NULL) || (!nodeExists(self,_node))) { return 0; }
        createLink(self, self.list[_node][PREV], self.list[_node][NEXT], NEXT);
        delete self.list[_node][PREV];
        delete self.list[_node][NEXT];
        return _node;
    }

    
    
    
    
    function push(LinkedList storage self, uint256 _node, bool _direction) internal  {
        insert(self, HEAD, _node, _direction);
    }
    
    
    
    
    function pop(LinkedList storage self, bool _direction) internal returns (uint256) {
        bool exists;
        uint256 adj;

        (exists,adj) = getAdjacent(self, HEAD, _direction);

        return remove(self, adj);
    }
}

















contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}




