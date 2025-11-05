pragma solidity 0.4.24;




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







contract EmcoVoucher is Ownable {

	address signerAddress;
	EmcoToken public token;

	mapping (uint => bool) usedNonces;

	event VoucherRedemption(address indexed caller, uint indexed nonce, uint amount);

	constructor(EmcoToken _token) public {
		require(_token != address(0), "token address should not be empty");
		token = _token;
	}

	



	function setSignerAddress(address _address) public onlyOwner {
		require(_address != address(0), "signer address should not be empty");
		signerAddress = _address;
	}

	




	function withdrawTokens(address _to, uint _amount) public onlyOwner {
		token.transfer(_to, _amount);
	}

	




	function isNonceUsed(uint _nonce) public view returns (bool isUsed) {
		return usedNonces[_nonce];
	}

	






	function activateVoucher(uint256 nonce, uint256 amount, bytes signature) public {
		require(!usedNonces[nonce], "nonce is already used");
		require(nonce != 0, "nonce should be greater than zero");
		require(amount != 0, "amount should be greater than zero");
		usedNonces[nonce] = true;

		address beneficiary = msg.sender;

		bytes32 message = prefixed(keccak256(abi.encodePacked(
			this,
			nonce,
			amount,
		  beneficiary)));

		address signedBy = recoverSigner(message, signature);
		require(signedBy == signerAddress);

		require(token.transfer(beneficiary, amount));
		emit VoucherRedemption(msg.sender, nonce, amount);
	}

	function splitSignature(bytes sig) internal pure returns (uint8, bytes32, bytes32) {
		require(sig.length == 65);

		bytes32 r;
		bytes32 s;
		uint8 v;

		assembly {
			r := mload(add(sig, 32))
			s := mload(add(sig, 64))
			v := byte(0, mload(add(sig, 96)))
		}

		return (v, r, s);
	}

	function recoverSigner(bytes32 message, bytes sig) internal pure returns (address) {
		uint8 v;
		bytes32 r;
		bytes32 s;

		(v, r, s) = splitSignature(sig);

		return ecrecover(message, v, r, s);
	}

	
	function prefixed(bytes32 hash) internal pure returns (bytes32) {
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
	}

}