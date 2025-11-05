pragma solidity 0.4.24;

interface AbstractENS {
    function owner(bytes32 _node) public constant returns (address);
    function resolver(bytes32 _node) public constant returns (address);
    function ttl(bytes32 _node) public constant returns (uint64);
    function setOwner(bytes32 _node, address _owner) public;
    function setSubnodeOwner(bytes32 _node, bytes32 label, address _owner) public;
    function setResolver(bytes32 _node, address _resolver) public;
    function setTTL(bytes32 _node, uint64 _ttl) public;

    
    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);

    
    event Transfer(bytes32 indexed _node, address _owner);

    
    event NewResolver(bytes32 indexed _node, address _resolver);

    
    event NewTTL(bytes32 indexed _node, uint64 _ttl);
}





contract ACL is IACL, TimeHelpers, AragonApp, ACLHelpers {
    


    bytes32 public constant CREATE_PERMISSIONS_ROLE = 0x0b719b33c83b8e5d300c521cb8b54ae9bd933996a14bef8c2f4e0285d2d2400a;

    enum Op { NONE, EQ, NEQ, GT, LT, GTE, LTE, RET, NOT, AND, OR, XOR, IF_ELSE } 

    struct Param {
        uint8 id;
        uint8 op;
        uint240 value; 
        
        
    }

    uint8 internal constant BLOCK_NUMBER_PARAM_ID = 200;
    uint8 internal constant TIMESTAMP_PARAM_ID    = 201;
    
    uint8 internal constant ORACLE_PARAM_ID       = 203;
    uint8 internal constant LOGIC_OP_PARAM_ID     = 204;
    uint8 internal constant PARAM_VALUE_PARAM_ID  = 205;
    

    


    bytes32 public constant EMPTY_PARAM_HASH = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
    bytes32 public constant NO_PERMISSION = bytes32(0);
    address public constant ANY_ENTITY = address(-1);
    address public constant BURN_ENTITY = address(1); 

    uint256 internal constant ORACLE_CHECK_GAS = 30000;

    string private constant ERROR_AUTH_INIT_KERNEL = "ACL_AUTH_INIT_KERNEL";
    string private constant ERROR_AUTH_NO_MANAGER = "ACL_AUTH_NO_MANAGER";
    string private constant ERROR_EXISTENT_MANAGER = "ACL_EXISTENT_MANAGER";

    
    mapping (bytes32 => bytes32) internal permissions; 
    mapping (bytes32 => Param[]) internal permissionParams; 

    
    mapping (bytes32 => address) internal permissionManager;

    event SetPermission(address indexed entity, address indexed app, bytes32 indexed role, bool allowed);
    event SetPermissionParams(address indexed entity, address indexed app, bytes32 indexed role, bytes32 paramsHash);
    event ChangePermissionManager(address indexed app, bytes32 indexed role, address indexed manager);

    modifier onlyPermissionManager(address _app, bytes32 _role) {
        require(msg.sender == getPermissionManager(_app, _role), ERROR_AUTH_NO_MANAGER);
        _;
    }

    modifier noPermissionManager(address _app, bytes32 _role) {
        
        require(getPermissionManager(_app, _role) == address(0), ERROR_EXISTENT_MANAGER);
        _;
    }

    




    function initialize(address _permissionsCreator) public onlyInit {
        initialized();
        require(msg.sender == address(kernel()), ERROR_AUTH_INIT_KERNEL);

        _createPermission(_permissionsCreator, this, CREATE_PERMISSIONS_ROLE, _permissionsCreator);
    }

    












    function createPermission(address _entity, address _app, bytes32 _role, address _manager)
        external
        auth(CREATE_PERMISSIONS_ROLE)
        noPermissionManager(_app, _role)
    {
        _createPermission(_entity, _app, _role, _manager);
    }

    






    function grantPermission(address _entity, address _app, bytes32 _role)
        external
    {
        grantPermissionP(_entity, _app, _role, new uint256[](0));
    }

    







    function grantPermissionP(address _entity, address _app, bytes32 _role, uint256[] _params)
        public
        onlyPermissionManager(_app, _role)
    {
        bytes32 paramsHash = _params.length > 0 ? _saveParams(_params) : EMPTY_PARAM_HASH;
        _setPermission(_entity, _app, _role, paramsHash);
    }

    






    function revokePermission(address _entity, address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermission(_entity, _app, _role, NO_PERMISSION);
    }

    





    function setPermissionManager(address _newManager, address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermissionManager(_newManager, _app, _role);
    }

    




    function removePermissionManager(address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermissionManager(address(0), _app, _role);
    }

    




    function createBurnedPermission(address _app, bytes32 _role)
        external
        auth(CREATE_PERMISSIONS_ROLE)
        noPermissionManager(_app, _role)
    {
        _setPermissionManager(BURN_ENTITY, _app, _role);
    }

    




    function burnPermissionManager(address _app, bytes32 _role)
        external
        onlyPermissionManager(_app, _role)
    {
        _setPermissionManager(BURN_ENTITY, _app, _role);
    }

    






    function getPermissionParamsLength(address _entity, address _app, bytes32 _role) external view returns (uint) {
        return permissionParams[permissions[permissionHash(_entity, _app, _role)]].length;
    }

    







    function getPermissionParam(address _entity, address _app, bytes32 _role, uint _index)
        external
        view
        returns (uint8, uint8, uint240)
    {
        Param storage param = permissionParams[permissions[permissionHash(_entity, _app, _role)]][_index];
        return (param.id, param.op, param.value);
    }

    





    function getPermissionManager(address _app, bytes32 _role) public view returns (address) {
        return permissionManager[roleHash(_app, _role)];
    }

    







    function hasPermission(address _who, address _where, bytes32 _what, bytes memory _how) public view returns (bool) {
        
        
        
        uint256[] memory how;
        uint256 intsLength = _how.length / 32;
        assembly {
            how := _how
            mstore(how, intsLength)
        }

        return hasPermission(_who, _where, _what, how);
    }

    function hasPermission(address _who, address _where, bytes32 _what, uint256[] memory _how) public view returns (bool) {
        bytes32 whoParams = permissions[permissionHash(_who, _where, _what)];
        if (whoParams != NO_PERMISSION && evalParams(whoParams, _who, _where, _what, _how)) {
            return true;
        }

        bytes32 anyParams = permissions[permissionHash(ANY_ENTITY, _where, _what)];
        if (anyParams != NO_PERMISSION && evalParams(anyParams, ANY_ENTITY, _where, _what, _how)) {
            return true;
        }

        return false;
    }

    function hasPermission(address _who, address _where, bytes32 _what) public view returns (bool) {
        uint256[] memory empty = new uint256[](0);
        return hasPermission(_who, _where, _what, empty);
    }

    function evalParams(
        bytes32 _paramsHash,
        address _who,
        address _where,
        bytes32 _what,
        uint256[] _how
    ) public view returns (bool)
    {
        if (_paramsHash == EMPTY_PARAM_HASH) {
            return true;
        }

        return _evalParam(_paramsHash, 0, _who, _where, _what, _how);
    }

    


    function _createPermission(address _entity, address _app, bytes32 _role, address _manager) internal {
        _setPermission(_entity, _app, _role, EMPTY_PARAM_HASH);
        _setPermissionManager(_manager, _app, _role);
    }

    


    function _setPermission(address _entity, address _app, bytes32 _role, bytes32 _paramsHash) internal {
        permissions[permissionHash(_entity, _app, _role)] = _paramsHash;
        bool entityHasPermission = _paramsHash != NO_PERMISSION;
        bool permissionHasParams = entityHasPermission && _paramsHash != EMPTY_PARAM_HASH;

        emit SetPermission(_entity, _app, _role, entityHasPermission);
        if (permissionHasParams) {
            emit SetPermissionParams(_entity, _app, _role, _paramsHash);
        }
    }

    function _saveParams(uint256[] _encodedParams) internal returns (bytes32) {
        bytes32 paramHash = keccak256(abi.encodePacked(_encodedParams));
        Param[] storage params = permissionParams[paramHash];

        if (params.length == 0) { 
            for (uint256 i = 0; i < _encodedParams.length; i++) {
                uint256 encodedParam = _encodedParams[i];
                Param memory param = Param(decodeParamId(encodedParam), decodeParamOp(encodedParam), uint240(encodedParam));
                params.push(param);
            }
        }

        return paramHash;
    }

    function _evalParam(
        bytes32 _paramsHash,
        uint32 _paramId,
        address _who,
        address _where,
        bytes32 _what,
        uint256[] _how
    ) internal view returns (bool)
    {
        if (_paramId >= permissionParams[_paramsHash].length) {
            return false; 
        }

        Param memory param = permissionParams[_paramsHash][_paramId];

        if (param.id == LOGIC_OP_PARAM_ID) {
            return _evalLogic(param, _paramsHash, _who, _where, _what, _how);
        }

        uint256 value;
        uint256 comparedTo = uint256(param.value);

        
        if (param.id == ORACLE_PARAM_ID) {
            value = checkOracle(IACLOracle(param.value), _who, _where, _what, _how) ? 1 : 0;
            comparedTo = 1;
        } else if (param.id == BLOCK_NUMBER_PARAM_ID) {
            value = getBlockNumber();
        } else if (param.id == TIMESTAMP_PARAM_ID) {
            value = getTimestamp();
        } else if (param.id == PARAM_VALUE_PARAM_ID) {
            value = uint256(param.value);
        } else {
            if (param.id >= _how.length) {
                return false;
            }
            value = uint256(uint240(_how[param.id])); 
        }

        if (Op(param.op) == Op.RET) {
            return uint256(value) > 0;
        }

        return compare(value, Op(param.op), comparedTo);
    }

    function _evalLogic(Param _param, bytes32 _paramsHash, address _who, address _where, bytes32 _what, uint256[] _how)
        internal
        view
        returns (bool)
    {
        if (Op(_param.op) == Op.IF_ELSE) {
            uint32 conditionParam;
            uint32 successParam;
            uint32 failureParam;

            (conditionParam, successParam, failureParam) = decodeParamsList(uint256(_param.value));
            bool result = _evalParam(_paramsHash, conditionParam, _who, _where, _what, _how);

            return _evalParam(_paramsHash, result ? successParam : failureParam, _who, _where, _what, _how);
        }

        uint32 param1;
        uint32 param2;

        (param1, param2,) = decodeParamsList(uint256(_param.value));
        bool r1 = _evalParam(_paramsHash, param1, _who, _where, _what, _how);

        if (Op(_param.op) == Op.NOT) {
            return !r1;
        }

        if (r1 && Op(_param.op) == Op.OR) {
            return true;
        }

        if (!r1 && Op(_param.op) == Op.AND) {
            return false;
        }

        bool r2 = _evalParam(_paramsHash, param2, _who, _where, _what, _how);

        if (Op(_param.op) == Op.XOR) {
            return r1 != r2;
        }

        return r2; 
    }

    function compare(uint256 _a, Op _op, uint256 _b) internal pure returns (bool) {
        if (_op == Op.EQ)  return _a == _b;                              
        if (_op == Op.NEQ) return _a != _b;                              
        if (_op == Op.GT)  return _a > _b;                               
        if (_op == Op.LT)  return _a < _b;                               
        if (_op == Op.GTE) return _a >= _b;                              
        if (_op == Op.LTE) return _a <= _b;                              
        return false;
    }

    function checkOracle(IACLOracle _oracleAddr, address _who, address _where, bytes32 _what, uint256[] _how) internal view returns (bool) {
        bytes4 sig = _oracleAddr.canPerform.selector;

        
        bytes memory checkCalldata = abi.encodeWithSelector(sig, _who, _where, _what, _how);
        uint256 oracleCheckGas = ORACLE_CHECK_GAS;

        bool ok;
        assembly {
            ok := staticcall(oracleCheckGas, _oracleAddr, add(checkCalldata, 0x20), mload(checkCalldata), 0, 0)
        }

        if (!ok) {
            return false;
        }

        uint256 size;
        assembly { size := returndatasize }
        if (size != 32) {
            return false;
        }

        bool result;
        assembly {
            let ptr := mload(0x40)       
            returndatacopy(ptr, 0, size) 
            result := mload(ptr)         
            mstore(ptr, 0)               
        }

        return result;
    }

    


    function _setPermissionManager(address _newManager, address _app, bytes32 _role) internal {
        permissionManager[roleHash(_app, _role)] = _newManager;
        emit ChangePermissionManager(_app, _role, _newManager);
    }

    function roleHash(address _where, bytes32 _what) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("ROLE", _where, _what));
    }

    function permissionHash(address _who, address _where, bytes32 _what) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("PERMISSION", _who, _where, _what));
    }
}


