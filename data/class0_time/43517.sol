pragma solidity ^0.4.13;








 




contract ProxyToken is MiniMeToken {

	function ProxyToken()  MiniMeToken(
		0x0,
		0x0,            
		0,              
		"Proxy Token", 	
		6,              
		"PRXY",         
		true            
	) {
		version = "Proxy 1.1";
	}
}