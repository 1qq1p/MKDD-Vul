contract Whitelist {
    address public owner;
    address public sale;

    mapping (address => uint) public accepted;

    function Whitelist() {
        owner = msg.sender;
    }

    
    function accept(address a, uint amount) {
        assert (msg.sender == owner || msg.sender == sale);

        accepted[a] = amount;
    }

    function setSale(address sale_) {
        assert (msg.sender == owner);

        sale = sale_;
    } 
}


contract DSStop is DSAuth, DSNote {

    bool public stopped;

    modifier stoppable {
        assert (!stopped);
        _;
    }
    function stop() auth note {
        stopped = true;
    }
    function start() auth note {
        stopped = false;
    }

}
