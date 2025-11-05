




contract Owned {
    
    modifier noEther() {if (msg.value > 0) throw; _}
    
    modifier onlyOwner { if (msg.sender != owner) throw; _ }

    address owner;

    function Owned() { owner = msg.sender;}



    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }

    function getOwner() noEther constant returns (address) {
        return owner;
    }
}
