pragma solidity 0.4.18;



interface FeeBurnerInterface {
    function handleFees (uint tradeWeiAmount, address reserve, address wallet) public returns(bool);
}




interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}




contract WrapFeeBurner is WrapperBase {

    FeeBurner public feeBurnerContract;
    address[] internal feeSharingWallets;
    uint public feeSharingBps = 3000; 

    
    struct KncPerEth {
        uint minRate;
        uint maxRate;
        uint pendingMinRate;
        uint pendingMaxRate;
    }

    KncPerEth internal kncPerEth;

    
    struct AddReserveData {
        address reserve;
        uint    feeBps;
        address kncWallet;
    }

    AddReserveData internal addReserve;

    
    struct WalletFee {
        address walletAddress;
        uint    feeBps;
    }

    WalletFee internal walletFee;

    
    struct TaxData {
        address wallet;
        uint    feeBps;
    }

    TaxData internal taxData;
    
    
    uint internal constant KNC_RATE_RANGE_INDEX = 0;
    uint internal constant ADD_RESERVE_INDEX = 1;
    uint internal constant WALLET_FEE_INDEX = 2;
    uint internal constant TAX_DATA_INDEX = 3;
    uint internal constant LAST_DATA_INDEX = 4;

    
    function WrapFeeBurner(FeeBurner feeBurner, address _admin) public
        WrapperBase(PermissionGroups(address(feeBurner)), _admin, LAST_DATA_INDEX)
    {
        require(feeBurner != address(0));
        feeBurnerContract = feeBurner;
    }

    
    
    function setFeeSharingValue(uint feeBps) public onlyAdmin {
        require(feeBps < 10000);
        feeSharingBps = feeBps;
    }

    function getFeeSharingWallets() public view returns(address[]) {
        return feeSharingWallets;
    }

    event WalletRegisteredForFeeSharing(address sender, address walletAddress);
    function registerWalletForFeeSharing(address walletAddress) public {
        require(feeBurnerContract.walletFeesInBps(walletAddress) == 0);

        
        feeBurnerContract.setWalletFees(walletAddress, feeSharingBps);
        feeSharingWallets.push(walletAddress);
        WalletRegisteredForFeeSharing(msg.sender, walletAddress);
    }

    
    
    function setPendingKNCRateRange(uint minRate, uint maxRate) public onlyOperator {
        require(minRate < maxRate);
        require(minRate > 0);

        
        setNewData(KNC_RATE_RANGE_INDEX);

        kncPerEth.pendingMinRate = minRate;
        kncPerEth.pendingMaxRate = maxRate;
    }

    function getPendingKNCRateRange() public view returns(uint minRate, uint maxRate, uint nonce) {
        address[] memory signatures;
        minRate = kncPerEth.pendingMinRate;
        maxRate = kncPerEth.pendingMaxRate;
        (signatures, nonce) = getDataTrackingParameters(KNC_RATE_RANGE_INDEX);

        return(minRate, maxRate, nonce);
    }

    function getKNCRateRangeSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(KNC_RATE_RANGE_INDEX);
        return(signatures);
    }

    function approveKNCRateRange(uint nonce) public onlyOperator {
        if (addSignature(KNC_RATE_RANGE_INDEX, nonce, msg.sender)) {
            
            kncPerEth.minRate = kncPerEth.pendingMinRate;
            kncPerEth.maxRate = kncPerEth.pendingMaxRate;
        }
    }

    function getKNCRateRange() public view returns(uint minRate, uint maxRate) {
        minRate = kncPerEth.minRate;
        maxRate = kncPerEth.maxRate;
        return(minRate, maxRate);
    }

    
    function setKNCPerEthRate(uint kncPerEther) public onlyOperator {
        require(kncPerEther >= kncPerEth.minRate);
        require(kncPerEther <= kncPerEth.maxRate);
        feeBurnerContract.setKNCRate(kncPerEther);
    }

    
    
    function setPendingReserveData(address reserve, uint feeBps, address kncWallet) public onlyOperator {
        require(reserve != address(0));
        require(kncWallet != address(0));
        require(feeBps > 0);
        require(feeBps < 10000);

        addReserve.reserve = reserve;
        addReserve.feeBps = feeBps;
        addReserve.kncWallet = kncWallet;
        setNewData(ADD_RESERVE_INDEX);
    }

    function getPendingAddReserveData() public view
        returns(address reserve, uint feeBps, address kncWallet, uint nonce)
    {
        address[] memory signatures;
        (signatures, nonce) = getDataTrackingParameters(ADD_RESERVE_INDEX);
        return(addReserve.reserve, addReserve.feeBps, addReserve.kncWallet, nonce);
    }

    function getAddReserveSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(ADD_RESERVE_INDEX);
        return(signatures);
    }

    function approveAddReserveData(uint nonce) public onlyOperator {
        if (addSignature(ADD_RESERVE_INDEX, nonce, msg.sender)) {
            
            feeBurnerContract.setReserveData(addReserve.reserve, addReserve.feeBps, addReserve.kncWallet);
        }
    }

    
    
    function setPendingWalletFee(address wallet, uint feeBps) public onlyOperator {
        require(wallet != address(0));
        require(feeBps > 0);
        require(feeBps < 10000);

        walletFee.walletAddress = wallet;
        walletFee.feeBps = feeBps;
        setNewData(WALLET_FEE_INDEX);
    }

    function getPendingWalletFeeData() public view returns(address wallet, uint feeBps, uint nonce) {
        address[] memory signatures;
        (signatures, nonce) = getDataTrackingParameters(WALLET_FEE_INDEX);
        return(walletFee.walletAddress, walletFee.feeBps, nonce);
    }

    function getWalletFeeSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(WALLET_FEE_INDEX);
        return(signatures);
    }

    function approveWalletFeeData(uint nonce) public onlyOperator {
        if (addSignature(WALLET_FEE_INDEX, nonce, msg.sender)) {
            
            feeBurnerContract.setWalletFees(walletFee.walletAddress, walletFee.feeBps);
        }
    }

    
    
    function setPendingTaxParameters(address taxWallet, uint feeBps) public onlyOperator {
        require(taxWallet != address(0));
        require(feeBps > 0);
        require(feeBps < 10000);

        taxData.wallet = taxWallet;
        taxData.feeBps = feeBps;
        setNewData(TAX_DATA_INDEX);
    }

    function getPendingTaxData() public view returns(address wallet, uint feeBps, uint nonce) {
        address[] memory signatures;
        (signatures, nonce) = getDataTrackingParameters(TAX_DATA_INDEX);
        return(taxData.wallet, taxData.feeBps, nonce);
    }

    function getTaxDataSignatures() public view returns (address[] signatures) {
        uint nonce;
        (signatures, nonce) = getDataTrackingParameters(TAX_DATA_INDEX);
        return(signatures);
    }

    function approveTaxData(uint nonce) public onlyOperator {
        if (addSignature(TAX_DATA_INDEX, nonce, msg.sender)) {
            
            feeBurnerContract.setTaxInBps(taxData.feeBps);
            feeBurnerContract.setTaxWallet(taxData.wallet);
        }
    }
}