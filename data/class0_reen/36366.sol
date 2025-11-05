pragma solidity ^0.4.17;

contract iTinyToken is MiniMeToken {
    
    function iTinyToken(address _tokenFactory)
            MiniMeToken(
                _tokenFactory,
                0x0,                         
                0,                           
                "iTinyToken",                
                18,                          
                "ITT",                       
                true                         
            ) {}
}