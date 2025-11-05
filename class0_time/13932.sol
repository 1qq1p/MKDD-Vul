pragma solidity ^0.4.24;






contract RepublicToken is PausableToken, BurnableToken {

    string public constant name = "Republic Token";
    string public constant symbol = "REN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * 10**uint256(decimals);

    
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function transferTokens(address beneficiary, uint256 amount) public onlyOwner returns (bool) {
        
        require(amount > 0);

        balances[owner] = balances[owner].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        emit Transfer(owner, beneficiary, amount);

        return true;
    }
}




library LinkedList {

    



    address public constant NULL = 0x0;

    




    struct Node {
        bool inList;
        address previous;
        address next;
    }

    



    struct List {
        mapping (address => Node) list;
    }

    






    function insertBefore(List storage self, address target, address newNode) internal {
        require(!isInList(self, newNode), "already in list");
        require(isInList(self, target) || target == NULL, "not in list");

        
        address prev = self.list[target].previous;

        self.list[newNode].next = target;
        self.list[newNode].previous = prev;
        self.list[target].previous = newNode;
        self.list[prev].next = newNode;

        self.list[newNode].inList = true;
    }

    






    function insertAfter(List storage self, address target, address newNode) internal {
        require(!isInList(self, newNode), "already in list");
        require(isInList(self, target) || target == NULL, "not in list");

        
        address n = self.list[target].next;

        self.list[newNode].previous = target;
        self.list[newNode].next = n;
        self.list[target].next = newNode;
        self.list[n].previous = newNode;

        self.list[newNode].inList = true;
    }

    







    function remove(List storage self, address node) internal {
        require(isInList(self, node), "not in list");
        if (node == NULL) {
            return;
        }
        address p = self.list[node].previous;
        address n = self.list[node].next;

        self.list[p].next = n;
        self.list[n].previous = p;

        
        
        self.list[node].inList = false;
        delete self.list[node];
    }

    





    function prepend(List storage self, address node) internal {
        

        insertBefore(self, begin(self), node);
    }

    





    function append(List storage self, address node) internal {
        

        insertAfter(self, end(self), node);
    }

    function swap(List storage self, address left, address right) internal {
        

        address previousRight = self.list[right].previous;
        remove(self, right);
        insertAfter(self, left, right);
        remove(self, left);
        insertAfter(self, previousRight, left);
    }

    function isInList(List storage self, address node) internal view returns (bool) {
        return self.list[node].inList;
    }

    







    function begin(List storage self) internal view returns (address) {
        return self.list[NULL].next;
    }

    







    function end(List storage self) internal view returns (address) {
        return self.list[NULL].previous;
    }

    function next(List storage self, address node) internal view returns (address) {
        require(isInList(self, node), "not in list");
        return self.list[node].next;
    }

    function previous(List storage self, address node) internal view returns (address) {
        require(isInList(self, node), "not in list");
        return self.list[node].previous;
    }

}



