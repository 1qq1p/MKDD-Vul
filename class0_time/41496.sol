pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

library Strings {

    










    function concat(string _base, string _value)
        internal
        pure
        returns (string) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length > 0);

        string memory _tmpValue = new string(_baseBytes.length + 
            _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i = 0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

    












    function indexOf(string _base, string _value)
        internal
        pure
        returns (int) {
        return _indexOf(_base, _value, 0);
    }

    















    function _indexOf(string _base, string _value, uint _offset)
        internal
        pure
        returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for(uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }

        return -1;
    }

    








    function length(string _base)
        internal
        pure
        returns (uint) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

    










    function substring(string _base, int _length)
        internal
        pure
        returns (string) {
        return _substring(_base, _length, 0);
    }

    












    function _substring(string _base, int _length, int _offset)
        internal
        pure
        returns (string) {
        bytes memory _baseBytes = bytes(_base);

        assert(uint(_offset+_length) <= _baseBytes.length);

        string memory _tmp = new string(uint(_length));
        bytes memory _tmpBytes = bytes(_tmp);

        uint j = 0;
        for(uint i = uint(_offset); i < uint(_offset+_length); i++) {
          _tmpBytes[j++] = _baseBytes[i];
        }

        return string(_tmpBytes);
    }

    













    function split(string _base, string _value)
        internal
        returns (string[] storage splitArr) {
        bytes memory _baseBytes = bytes(_base);
        uint _offset = 0;

        while(_offset < _baseBytes.length-1) {

            int _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1) {
                _limit = int(_baseBytes.length);
            }

            string memory _tmp = new string(uint(_limit)-_offset);
            bytes memory _tmpBytes = bytes(_tmp);

            uint j = 0;
            for(uint i = _offset; i < uint(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint(_limit) + 1;
            splitArr.push(string(_tmpBytes));
        }
        return splitArr;
    }

    










    function compareTo(string _base, string _value) 
        internal
        pure
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for(uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i]) {
                return false;
            }
        }

        return true;
    }

    












    function compareToIgnoreCase(string _base, string _value)
        internal
        pure
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for(uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i] && 
                _upper(_baseBytes[i]) != _upper(_valueBytes[i])) {
                return false;
            }
        }

        return true;
    }

    









    function upper(string _base) 
        internal
        pure
        returns (string) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    









    function lower(string _base) 
        internal
        pure
        returns (string) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    









    function _upper(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1)-32);
        }

        return _b1;
    }

    









    function _lower(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1)+32);
        }
        
        return _b1;
    }
}

contract PartnerFund is Ownable, Beneficiary, TransferControllerManageable {
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using TxHistoryLib for TxHistoryLib.TxHistory;
    using SafeMathIntLib for int256;
    using Strings for string;

    
    
    
    struct Partner {
        bytes32 nameHash;

        uint256 fee;
        address wallet;
        uint256 index;

        bool operatorCanUpdate;
        bool partnerCanUpdate;

        FungibleBalanceLib.Balance active;
        FungibleBalanceLib.Balance staged;

        TxHistoryLib.TxHistory txHistory;
        FullBalanceHistory[] fullBalanceHistory;
    }

    struct FullBalanceHistory {
        uint256 listIndex;
        int256 balance;
        uint256 blockNumber;
    }

    
    
    
    Partner[] private partners;

    mapping(bytes32 => uint256) private _indexByNameHash;
    mapping(address => uint256) private _indexByWallet;

    
    
    
    event ReceiveEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event RegisterPartnerByNameEvent(string name, uint256 fee, address wallet);
    event RegisterPartnerByNameHashEvent(bytes32 nameHash, uint256 fee, address wallet);
    event SetFeeByIndexEvent(uint256 index, uint256 oldFee, uint256 newFee);
    event SetFeeByNameEvent(string name, uint256 oldFee, uint256 newFee);
    event SetFeeByNameHashEvent(bytes32 nameHash, uint256 oldFee, uint256 newFee);
    event SetFeeByWalletEvent(address wallet, uint256 oldFee, uint256 newFee);
    event SetPartnerWalletByIndexEvent(uint256 index, address oldWallet, address newWallet);
    event SetPartnerWalletByNameEvent(string name, address oldWallet, address newWallet);
    event SetPartnerWalletByNameHashEvent(bytes32 nameHash, address oldWallet, address newWallet);
    event SetPartnerWalletByWalletEvent(address oldWallet, address newWallet);
    event StageEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event WithdrawEvent(address to, int256 amount, address currencyCt, uint256 currencyId);

    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    
    function() public payable {
        _receiveEthersTo(
            indexByWallet(msg.sender) - 1, SafeMathIntLib.toNonZeroInt256(msg.value)
        );
    }

    
    
    function receiveEthersTo(address tag, string)
    public
    payable
    {
        _receiveEthersTo(
            uint256(tag) - 1, SafeMathIntLib.toNonZeroInt256(msg.value)
        );
    }

    
    
    
    
    
    function receiveTokens(string, int256 amount, address currencyCt,
        uint256 currencyId, string standard)
    public
    {
        _receiveTokensTo(
            indexByWallet(msg.sender) - 1, amount, currencyCt, currencyId, standard
        );
    }

    
    
    
    
    
    
    function receiveTokensTo(address tag, string, int256 amount, address currencyCt,
        uint256 currencyId, string standard)
    public
    {
        _receiveTokensTo(
            uint256(tag) - 1, amount, currencyCt, currencyId, standard
        );
    }

    
    
    
    function hashName(string name)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(name.upper()));
    }

    
    
    
    
    function depositByIndices(uint256 partnerIndex, uint256 depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        
        require(0 < partnerIndex && partnerIndex <= partners.length);

        return _depositByIndices(partnerIndex - 1, depositIndex);
    }

    
    
    
    
    function depositByName(string name, uint depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        
        return _depositByIndices(indexByName(name) - 1, depositIndex);
    }

    
    
    
    
    function depositByNameHash(bytes32 nameHash, uint depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        
        return _depositByIndices(indexByNameHash(nameHash) - 1, depositIndex);
    }

    
    
    
    
    function depositByWallet(address wallet, uint depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        
        return _depositByIndices(indexByWallet(wallet) - 1, depositIndex);
    }

    
    
    
    function depositsCountByIndex(uint256 index)
    public
    view
    returns (uint256)
    {
        
        require(0 < index && index <= partners.length);

        return _depositsCountByIndex(index - 1);
    }

    
    
    
    function depositsCountByName(string name)
    public
    view
    returns (uint256)
    {
        
        return _depositsCountByIndex(indexByName(name) - 1);
    }

    
    
    
    function depositsCountByNameHash(bytes32 nameHash)
    public
    view
    returns (uint256)
    {
        
        return _depositsCountByIndex(indexByNameHash(nameHash) - 1);
    }

    
    
    
    function depositsCountByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        
        return _depositsCountByIndex(indexByWallet(wallet) - 1);
    }

    
    
    
    
    
    function activeBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        require(0 < index && index <= partners.length);

        return _activeBalanceByIndex(index - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function activeBalanceByName(string name, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        return _activeBalanceByIndex(indexByName(name) - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function activeBalanceByNameHash(bytes32 nameHash, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        return _activeBalanceByIndex(indexByNameHash(nameHash) - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function activeBalanceByWallet(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        return _activeBalanceByIndex(indexByWallet(wallet) - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function stagedBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        require(0 < index && index <= partners.length);

        return _stagedBalanceByIndex(index - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function stagedBalanceByName(string name, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        return _stagedBalanceByIndex(indexByName(name) - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function stagedBalanceByNameHash(bytes32 nameHash, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        return _stagedBalanceByIndex(indexByNameHash(nameHash) - 1, currencyCt, currencyId);
    }

    
    
    
    
    
    function stagedBalanceByWallet(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        
        return _stagedBalanceByIndex(indexByWallet(wallet) - 1, currencyCt, currencyId);
    }

    
    
    function partnersCount()
    public
    view
    returns (uint256)
    {
        return partners.length;
    }

    
    
    
    
    
    
    function registerByName(string name, uint256 fee, address wallet,
        bool partnerCanUpdate, bool operatorCanUpdate)
    public
    onlyOperator
    {
        
        require(bytes(name).length > 0);

        
        bytes32 nameHash = hashName(name);

        
        _registerPartnerByNameHash(nameHash, fee, wallet, partnerCanUpdate, operatorCanUpdate);

        
        emit RegisterPartnerByNameEvent(name, fee, wallet);
    }

    
    
    
    
    
    
    function registerByNameHash(bytes32 nameHash, uint256 fee, address wallet,
        bool partnerCanUpdate, bool operatorCanUpdate)
    public
    onlyOperator
    {
        
        _registerPartnerByNameHash(nameHash, fee, wallet, partnerCanUpdate, operatorCanUpdate);

        
        emit RegisterPartnerByNameHashEvent(nameHash, fee, wallet);
    }

    
    
    
    function indexByNameHash(bytes32 nameHash)
    public
    view
    returns (uint256)
    {
        uint256 index = _indexByNameHash[nameHash];
        require(0 < index);
        return index;
    }

    
    
    
    function indexByName(string name)
    public
    view
    returns (uint256)
    {
        return indexByNameHash(hashName(name));
    }

    
    
    
    function indexByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        uint256 index = _indexByWallet[wallet];
        require(0 < index);
        return index;
    }

    
    
    
    function isRegisteredByName(string name)
    public
    view
    returns (bool)
    {
        return (0 < _indexByNameHash[hashName(name)]);
    }

    
    
    
    function isRegisteredByNameHash(bytes32 nameHash)
    public
    view
    returns (bool)
    {
        return (0 < _indexByNameHash[nameHash]);
    }

    
    
    
    function isRegisteredByWallet(address wallet)
    public
    view
    returns (bool)
    {
        return (0 < _indexByWallet[wallet]);
    }

    
    
    
    function feeByIndex(uint256 index)
    public
    view
    returns (uint256)
    {
        
        require(0 < index && index <= partners.length);

        return _partnerFeeByIndex(index - 1);
    }

    
    
    
    function feeByName(string name)
    public
    view
    returns (uint256)
    {
        
        return _partnerFeeByIndex(indexByName(name) - 1);
    }

    
    
    
    function feeByNameHash(bytes32 nameHash)
    public
    view
    returns (uint256)
    {
        
        return _partnerFeeByIndex(indexByNameHash(nameHash) - 1);
    }

    
    
    
    function feeByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        
        return _partnerFeeByIndex(indexByWallet(wallet) - 1);
    }

    
    
    
    function setFeeByIndex(uint256 index, uint256 newFee)
    public
    {
        
        require(0 < index && index <= partners.length);

        
        uint256 oldFee = _setPartnerFeeByIndex(index - 1, newFee);

        
        emit SetFeeByIndexEvent(index, oldFee, newFee);
    }

    
    
    
    function setFeeByName(string name, uint256 newFee)
    public
    {
        
        uint256 oldFee = _setPartnerFeeByIndex(indexByName(name) - 1, newFee);

        
        emit SetFeeByNameEvent(name, oldFee, newFee);
    }

    
    
    
    function setFeeByNameHash(bytes32 nameHash, uint256 newFee)
    public
    {
        
        uint256 oldFee = _setPartnerFeeByIndex(indexByNameHash(nameHash) - 1, newFee);

        
        emit SetFeeByNameHashEvent(nameHash, oldFee, newFee);
    }

    
    
    
    function setFeeByWallet(address wallet, uint256 newFee)
    public
    {
        
        uint256 oldFee = _setPartnerFeeByIndex(indexByWallet(wallet) - 1, newFee);

        
        emit SetFeeByWalletEvent(wallet, oldFee, newFee);
    }

    
    
    
    function walletByIndex(uint256 index)
    public
    view
    returns (address)
    {
        
        require(0 < index && index <= partners.length);

        return partners[index - 1].wallet;
    }

    
    
    
    function walletByName(string name)
    public
    view
    returns (address)
    {
        
        return partners[indexByName(name) - 1].wallet;
    }

    
    
    
    function walletByNameHash(bytes32 nameHash)
    public
    view
    returns (address)
    {
        
        return partners[indexByNameHash(nameHash) - 1].wallet;
    }

    
    
    
    function setWalletByIndex(uint256 index, address newWallet)
    public
    {
        
        require(0 < index && index <= partners.length);

        
        address oldWallet = _setPartnerWalletByIndex(index - 1, newWallet);

        
        emit SetPartnerWalletByIndexEvent(index, oldWallet, newWallet);
    }

    
    
    
    function setWalletByName(string name, address newWallet)
    public
    {
        
        address oldWallet = _setPartnerWalletByIndex(indexByName(name) - 1, newWallet);

        
        emit SetPartnerWalletByNameEvent(name, oldWallet, newWallet);
    }

    
    
    
    function setWalletByNameHash(bytes32 nameHash, address newWallet)
    public
    {
        
        address oldWallet = _setPartnerWalletByIndex(indexByNameHash(nameHash) - 1, newWallet);

        
        emit SetPartnerWalletByNameHashEvent(nameHash, oldWallet, newWallet);
    }

    
    
    
    function setWalletByWallet(address oldWallet, address newWallet)
    public
    {
        
        _setPartnerWalletByIndex(indexByWallet(oldWallet) - 1, newWallet);

        
        emit SetPartnerWalletByWalletEvent(oldWallet, newWallet);
    }

    
    
    
    
    function stage(int256 amount, address currencyCt, uint256 currencyId)
    public
    {
        
        uint256 index = indexByWallet(msg.sender);

        
        require(amount.isPositiveInt256());

        
        amount = amount.clampMax(partners[index - 1].active.get(currencyCt, currencyId));

        partners[index - 1].active.sub(amount, currencyCt, currencyId);
        partners[index - 1].staged.add(amount, currencyCt, currencyId);

        partners[index - 1].txHistory.addDeposit(amount, currencyCt, currencyId);

        
        partners[index - 1].fullBalanceHistory.push(
            FullBalanceHistory(
                partners[index - 1].txHistory.depositsCount() - 1,
                partners[index - 1].active.get(currencyCt, currencyId),
                block.number
            )
        );

        
        emit StageEvent(msg.sender, amount, currencyCt, currencyId);
    }

    
    
    
    
    
    function withdraw(int256 amount, address currencyCt, uint256 currencyId, string standard)
    public
    {
        
        uint256 index = indexByWallet(msg.sender);

        
        require(amount.isPositiveInt256());

        
        amount = amount.clampMax(partners[index - 1].staged.get(currencyCt, currencyId));

        partners[index - 1].staged.sub(amount, currencyCt, currencyId);

        
        if (address(0) == currencyCt && 0 == currencyId)
            msg.sender.transfer(uint256(amount));

        else {
            TransferController controller = transferController(currencyCt, standard);
            require(
                address(controller).delegatecall(
                    controller.getDispatchSignature(), this, msg.sender, uint256(amount), currencyCt, currencyId
                )
            );
        }

        
        emit WithdrawEvent(msg.sender, amount, currencyCt, currencyId);
    }

    
    
    
    
    function _receiveEthersTo(uint256 index, int256 amount)
    private
    {
        
        require(index < partners.length);

        
        partners[index].active.add(amount, address(0), 0);
        partners[index].txHistory.addDeposit(amount, address(0), 0);

        
        partners[index].fullBalanceHistory.push(
            FullBalanceHistory(
                partners[index].txHistory.depositsCount() - 1,
                partners[index].active.get(address(0), 0),
                block.number
            )
        );

        
        emit ReceiveEvent(msg.sender, amount, address(0), 0);
    }

    
    function _receiveTokensTo(uint256 index, int256 amount, address currencyCt,
        uint256 currencyId, string standard)
    private
    {
        
        require(index < partners.length);

        require(amount.isNonZeroPositiveInt256());

        
        TransferController controller = transferController(currencyCt, standard);
        require(
            address(controller).delegatecall(
                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId
            )
        );

        
        partners[index].active.add(amount, currencyCt, currencyId);
        partners[index].txHistory.addDeposit(amount, currencyCt, currencyId);

        
        partners[index].fullBalanceHistory.push(
            FullBalanceHistory(
                partners[index].txHistory.depositsCount() - 1,
                partners[index].active.get(currencyCt, currencyId),
                block.number
            )
        );

        
        emit ReceiveEvent(msg.sender, amount, currencyCt, currencyId);
    }

    
    function _depositByIndices(uint256 partnerIndex, uint256 depositIndex)
    private
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        require(depositIndex < partners[partnerIndex].fullBalanceHistory.length);

        FullBalanceHistory storage entry = partners[partnerIndex].fullBalanceHistory[depositIndex];
        (,, currencyCt, currencyId) = partners[partnerIndex].txHistory.deposit(entry.listIndex);

        balance = entry.balance;
        blockNumber = entry.blockNumber;
    }

    
    function _depositsCountByIndex(uint256 index)
    private
    view
    returns (uint256)
    {
        return partners[index].fullBalanceHistory.length;
    }

    
    function _activeBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    private
    view
    returns (int256)
    {
        return partners[index].active.get(currencyCt, currencyId);
    }

    
    function _stagedBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    private
    view
    returns (int256)
    {
        return partners[index].staged.get(currencyCt, currencyId);
    }

    function _registerPartnerByNameHash(bytes32 nameHash, uint256 fee, address wallet,
        bool partnerCanUpdate, bool operatorCanUpdate)
    private
    {
        
        require(0 == _indexByNameHash[nameHash]);

        
        require(partnerCanUpdate || operatorCanUpdate);

        
        partners.length++;

        
        uint256 index = partners.length;

        
        partners[index - 1].nameHash = nameHash;
        partners[index - 1].fee = fee;
        partners[index - 1].wallet = wallet;
        partners[index - 1].partnerCanUpdate = partnerCanUpdate;
        partners[index - 1].operatorCanUpdate = operatorCanUpdate;
        partners[index - 1].index = index;

        
        _indexByNameHash[nameHash] = index;

        
        _indexByWallet[wallet] = index;
    }

    
    function _setPartnerFeeByIndex(uint256 index, uint256 fee)
    private
    returns (uint256)
    {
        uint256 oldFee = partners[index].fee;

        
        if (isOperator())
            require(partners[index].operatorCanUpdate);

        else {
            
            require(msg.sender == partners[index].wallet);

            
            require(partners[index].partnerCanUpdate);
        }

        
        partners[index].fee = fee;

        return oldFee;
    }

    
    function _setPartnerWalletByIndex(uint256 index, address newWallet)
    private
    returns (address)
    {
        address oldWallet = partners[index].wallet;

        
        if (oldWallet == address(0))
            require(isOperator());

        
        else if (isOperator())
            require(partners[index].operatorCanUpdate);

        else {
            
            require(msg.sender == oldWallet);

            
            require(partners[index].partnerCanUpdate);

            
            require(partners[index].operatorCanUpdate || newWallet != address(0));
        }

        
        partners[index].wallet = newWallet;

        
        if (oldWallet != address(0))
            _indexByWallet[oldWallet] = 0;
        if (newWallet != address(0))
            _indexByWallet[newWallet] = index;

        return oldWallet;
    }

    
    function _partnerFeeByIndex(uint256 index)
    private
    view
    returns (uint256)
    {
        return partners[index].fee;
    }
}
