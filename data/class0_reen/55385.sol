pragma solidity ^0.4.13;


contract admined {
	address public admin;
    address public coAdmin;

	function admined() {
		admin = msg.sender;
        coAdmin = msg.sender;
	}

	modifier onlyAdmin(){
		require((msg.sender == admin) || (msg.sender == coAdmin)) ;
		_;
	}

	function transferAdminship(address newAdmin) onlyAdmin {
		admin = newAdmin;
	}

    function transferCoadminship(address newCoadmin) onlyAdmin {
		coAdmin = newCoadmin;
	}


} 
