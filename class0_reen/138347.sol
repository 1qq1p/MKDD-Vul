pragma solidity 0.4.20;



















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

































contract OraclizeI {
    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);

    function getPrice(string _datasource) returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);

    function useCoupon(string _coupon);

    function setProofType(byte _proofType);

    function setConfig(bytes32 _config);

    function setCustomGasPrice(uint _gasPrice);

    function randomDS_getSessionPubKeyHash() returns (bytes32);
}
