pragma solidity ^0.4.21;



interface Bankroll {

    

    
    function credit(address _customerAddress, uint256 amount) external returns (uint256);

    
    function debit(address _customerAddress, uint256 amount) external returns (uint256);

    
    function withdraw(address _customerAddress) external returns (uint256);

    
    function balanceOf(address _customerAddress) external view returns (uint256);

    
    function statsOf(address _customerAddress) external view returns (uint256[8]);


    

    
    function deposit() external payable;

    
    function depositBy(address _customerAddress) external payable;

    
    function houseProfit(uint256 amount)  external;


    
    function netEthereumBalance() external view returns (uint256);


    
    function totalEthereumBalance() external view returns (uint256);

}




contract SessionQueue {

    mapping(uint256 => address) private queue;
    uint256 private first = 1;
    uint256 private last = 0;

    
    function enqueue(address data) internal {
        last += 1;
        queue[last] = data;
    }

    
    function available() internal view returns (bool) {
        return last >= first;
    }

    
    function depth() internal view returns (uint256) {
        return last - first + 1;
    }

    
    function dequeue() internal returns (address data) {
        require(last >= first);
        

        data = queue[first];

        delete queue[first];
        first += 1;
    }

    
    function peek() internal view returns (address data) {
        require(last >= first);
        

        data = queue[first];
    }
}







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}







