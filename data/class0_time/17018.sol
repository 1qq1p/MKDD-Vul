pragma solidity ^0.4.22;


contract IEscrow is Withdrawable {

    

    
    enum PaymentStatus {NONE, CREATED, SIGNED, CONFIRMED, RELEASED, RELEASED_BY_DISPUTE , CLOSED, CANCELED}
    
    

    event PaymentCreated(bytes32 paymentId, address depositor, address beneficiary, address token, bytes32 deal, uint256 amount, uint8 fee, bool feePayed);
    event PaymentSigned(bytes32 paymentId, bool confirmed);
    event PaymentDeposited(bytes32 paymentId, uint256 depositedAmount, bool confirmed);
    event PaymentReleased(bytes32 paymentId);
    event PaymentOffer(bytes32 paymentId, uint256 offerAmount);
    event PaymentOfferCanceled(bytes32 paymentId);
    event PaymentOwnOfferCanceled(bytes32 paymentId);
    event PaymentOfferAccepted(bytes32 paymentId, uint256 releaseToBeneficiary, uint256 refundToDepositor);
    event PaymentWithdrawn(bytes32 paymentId, uint256 amount);
    event PaymentWithdrawnByDispute(bytes32 paymentId, uint256 amount, bytes32 dispute);
    event PaymentCanceled(bytes32 paymentId);
    event PaymentClosed(bytes32 paymentId);
    event PaymentClosedByDispute(bytes32 paymentId, bytes32 dispute);

    

    address public lib;
    address public courtAddress;
    address public paymentHolder;


    
    function setStorageAddress(address _storageAddress) external;

    function setCourtAddress(address _courtAddress) external;

    
    



    function createPayment(address[3] addresses, bytes32 deal, uint256 amount, bool depositorPayFee) external;

    


    function sign(address[3] addresses, bytes32 deal, uint256 amount) external;

    


    function deposit(address[3] addresses, bytes32 deal, uint256 amount) external payable;

    



    function cancel(address[3] addresses, bytes32 deal, uint256 amount) external;

    


    function release(address[3] addresses, bytes32 deal, uint256 amount) external;

    



    function offer(address[3] addresses, bytes32 deal, uint256 amount, uint256 offerAmount) external;

    


    function cancelOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

    


    function cancelOwnOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

    


    function acceptOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

   
    


    function withdraw(address[3] addresses, bytes32 deal, uint256 amount) external;

    






    function withdrawByDispute(address[3] addresses, address[2] disputeParties, uint256[3] uints, bytes32[2] byts) external;
}

library FeeLib {

    function getTotalFee(address storageAddress, address token)
    public view returns(uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.fee.total", token)));
    }

    function setTotalFee(address storageAddress, uint256 value, address token)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.fee.total", token)), value);
    }

    function addFee(address storageAddress, uint256 value, address token)
    public {
        uint256 newTotalFee = getTotalFee(storageAddress, token) + value;
        setTotalFee(storageAddress, newTotalFee, token);
    }

    
}

library PaymentLib {

    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addresses[0], addresses[1], addresses[2], deal, amount));
    }

    function createPayment(
        address storageAddress, bytes32 paymentId, uint8 fee, uint8 status, bool feePayed
    ) public {
        setPaymentStatus(storageAddress, paymentId, status);
        setPaymentFee(storageAddress, paymentId, fee);
        if (feePayed) {
            setFeePayed(storageAddress, paymentId, true);
        }
    }

    function isCancelRequested(address storageAddress, bytes32 paymentId, address party)
    public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.cance", paymentId, party)));
    }

    function setCancelRequested(address storageAddress, bytes32 paymentId, address party, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.cance", paymentId, party)), value);
    }

    function getPaymentFee(address storageAddress, bytes32 paymentId)
    public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("payment.fee", paymentId)));
    }

    function setPaymentFee(address storageAddress, bytes32 paymentId, uint8 value)
    public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("payment.fee", paymentId)), value);
    }

    function isFeePayed(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.fee.payed", paymentId)));
    }

    function setFeePayed(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.fee.payed", paymentId)), value);
    }

    function isDeposited(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.deposited", paymentId)));
    }

    function setDeposited(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.deposited", paymentId)), value);
    }

    function isSigned(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.signed", paymentId)));
    }

    function setSigned(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.signed", paymentId)), value);
    }

    function getPaymentStatus(address storageAddress, bytes32 paymentId)
    public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("payment.status", paymentId)));
    }

    function setPaymentStatus(address storageAddress, bytes32 paymentId, uint8 status)
    public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("payment.status", paymentId)), status);
    }

    function getOfferAmount(address storageAddress, bytes32 paymentId, address user)
    public view returns (uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.amount.refund", paymentId, user)));
    }

    function setOfferAmount(address storageAddress, bytes32 paymentId, address user, uint256 amount)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.amount.refund", paymentId, user)), amount);
    }

    function getWithdrawAmount(address storageAddress, bytes32 paymentId, address user)
    public view returns (uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.amount.withdraw", paymentId, user)));
    }

    function setWithdrawAmount(address storageAddress, bytes32 paymentId, address user, uint256 amount)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.amount.withdraw", paymentId, user)), amount);
    }

    function isWithdrawn(address storageAddress, bytes32 paymentId, address user)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.withdrawed", paymentId, user)));
    }

    function setWithdrawn(address storageAddress, bytes32 paymentId, address user, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.withdrawed", paymentId, user)), value);
    }

    function getPayment(address storageAddress, bytes32 paymentId)
    public view returns(
        uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited
    ) {
        status = uint8(getPaymentStatus(storageAddress, paymentId));
        fee = getPaymentFee(storageAddress, paymentId);
        feePayed = isFeePayed(storageAddress, paymentId);
        signed = isSigned(storageAddress, paymentId);
        deposited = isDeposited(storageAddress, paymentId);
    }

    function getPaymentOffers(address storageAddress, address depositor, address beneficiary, bytes32 paymentId)
    public view returns(uint256 depositorOffer, uint256 beneficiaryOffer) {
        depositorOffer = getOfferAmount(storageAddress, paymentId, depositor);
        beneficiaryOffer = getOfferAmount(storageAddress, paymentId, beneficiary);
    }
}
