pragma solidity ^0.4.17;






pragma solidity ^0.4.17;



contract AccessManager {
    

    

    address public server; 
    address public populous; 

    

    


    function AccessManager(address _server) public {
        server = _server;
        
    }

    



    function changeServer(address _server) public {
        require(isServer(msg.sender) == true);
        server = _server;
    }

    


    




    



    function changePopulous(address _populous) public {
        require(isServer(msg.sender) == true);
        populous = _populous;
    }

    
    
    



    function isServer(address sender) public view returns (bool) {
        return sender == server;
    }

    



    



    



    function isPopulous(address sender) public view returns (bool) {
        return sender == populous;
    }

}



