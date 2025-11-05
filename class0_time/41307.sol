pragma solidity ^0.4.24;
pragma experimental "v0.5.0";
pragma experimental ABIEncoderV2;

library AddressExtension {

  function isValid(address _address) internal pure returns (bool) {
    return 0 != _address;
  }

  function isAccount(address _address) internal view returns (bool result) {
    assembly {
      result := iszero(extcodesize(_address))
    }
  }

  function toBytes(address _address) internal pure returns (bytes b) {
   assembly {
      let m := mload(0x40)
      mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, _address))
      mstore(0x40, add(m, 52))
      b := m
    }
  }
}

library Math {

  struct Fraction {
    uint256 numerator;
    uint256 denominator;
  }

  function isPositive(Fraction memory fraction) internal pure returns (bool) {
    return fraction.numerator > 0 && fraction.denominator > 0;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 r) {
    r = a * b;
    require((a == 0) || (r / a == b));
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 r) {
    r = a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 r) {
    require((r = a - b) <= a);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 r) {
    require((r = a + b) >= a);
  }

  function min(uint256 x, uint256 y) internal pure returns (uint256 r) {
    return x <= y ? x : y;
  }

  function max(uint256 x, uint256 y) internal pure returns (uint256 r) {
    return x >= y ? x : y;
  }

  function mulDiv(uint256 value, uint256 m, uint256 d) internal pure returns (uint256 r) {
    r = value * m;
    if (r / value == m) {
      r /= d;
    } else {
      r = mul(value / d, m);
    }
  }

  function mulDivCeil(uint256 value, uint256 m, uint256 d) internal pure returns (uint256 r) {
    r = value * m;
    if (r / value == m) {
      if (r % d == 0) {
        r /= d;
      } else {
        r = (r / d) + 1;
      }
    } else {
      r = mul(value / d, m);
      if (value % d != 0) {
        r += 1;
      }
    }
  }

  function mul(uint256 x, Fraction memory f) internal pure returns (uint256) {
    return mulDiv(x, f.numerator, f.denominator);
  }

  function mulCeil(uint256 x, Fraction memory f) internal pure returns (uint256) {
    return mulDivCeil(x, f.numerator, f.denominator);
  }

  function div(uint256 x, Fraction memory f) internal pure returns (uint256) {
    return mulDiv(x, f.denominator, f.numerator);
  }

  function divCeil(uint256 x, Fraction memory f) internal pure returns (uint256) {
    return mulDivCeil(x, f.denominator, f.numerator);
  }

  function mul(Fraction memory x, Fraction memory y) internal pure returns (Math.Fraction) {
    return Math.Fraction({
      numerator: mul(x.numerator, y.numerator),
      denominator: mul(x.denominator, y.denominator)
    });
  }
}

contract FsTKToken {

  enum DelegateMode { PublicMsgSender, PublicTxOrigin, PrivateMsgSender, PrivateTxOrigin }

  event Consume(address indexed from, uint256 value, bytes32 challenge);
  event IncreaseNonce(address indexed from, uint256 nonce);
  event SetupDirectDebit(address indexed debtor, address indexed receiver, DirectDebitInfo info);
  event TerminateDirectDebit(address indexed debtor, address indexed receiver);
  event WithdrawDirectDebitFailure(address indexed debtor, address indexed receiver);

  event SetMetadata(string metadata);
  event SetLiquid(bool liquidity);
  event SetDelegate(bool isDelegateEnable);
  event SetDirectDebit(bool isDirectDebitEnable);

  struct DirectDebitInfo {
    uint256 amount;
    uint256 startTime;
    uint256 interval;
  }
  struct DirectDebit {
    DirectDebitInfo info;
    uint256 epoch;
  }
  struct Instrument {
    uint256 allowance;
    DirectDebit directDebit;
  }
  struct Account {
    uint256 balance;
    uint256 nonce;
    mapping (address => Instrument) instruments;
  }

  function spendableAllowance(address owner, address spender) public view returns (uint256);
  function transfer(uint256[] data) public returns (bool);
  function transferAndCall(address to, uint256 value, bytes data) public payable returns (bool);

  function nonceOf(address owner) public view returns (uint256);
  function increaseNonce() public returns (bool);
  function delegateTransferAndCall(
    uint256 nonce,
    uint256 fee,
    uint256 gasAmount,
    address to,
    uint256 value,
    bytes data,
    DelegateMode mode,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public returns (bool);

  function directDebit(address debtor, address receiver) public view returns (DirectDebit);
  function setupDirectDebit(address receiver, DirectDebitInfo info) public returns (bool);
  function terminateDirectDebit(address receiver) public returns (bool);
  function withdrawDirectDebit(address debtor) public returns (bool);
  function withdrawDirectDebit(address[] debtors, bool strict) public returns (bool);
}
