












pragma solidity ^0.4.21;


contract ChainmonstersShop {
    using SafeMath for uint256; 
    
    
    address public owner;
    
    
    bool started;

    uint256 public totalCoinsSold;

    address medianizer;
    uint256 shiftValue = 100; 
    uint256 multiplier = 10000; 

    struct Package {
        
        uint256 price;
        
        string packageReference;
        
        bool isActive;
        
        uint256 coinsAmount;
    }

    
    event LogPurchase(address _from, uint256 _price, string _packageReference);

    mapping(address => uint256) public addressToCoinsPurchased;
    Package[] packages;

    constructor() public {
        owner = msg.sender;

        started = false;
        
        _addPackage(99, "100 Coins", true, 100);
        _addPackage(549, "550 Coins", true, 550);
        _addPackage(1099, "1200 Coins", true, 1200);
        _addPackage(2199, "2500 Coins", true, 2500);
        _addPackage(4399, "5200 Coins", true, 5200);
        _addPackage(10999, "14500 Coins", true, 14500);
        
    }

    function startShop() public onlyOwner {
        require(started == false);
        started = true;
    }

    
    function pauseShop() public onlyOwner {
        require(started == true);
        started = false;
    }

    function isStarted() public view returns (bool success) {
        return started;
    }

    function purchasePackage(uint256 _id) public
        payable
        returns (bool success)
        {
            require(started == true);
            require(packages[_id].isActive == true);
            require(msg.sender != owner);
            require(msg.value == priceOf(_id)); 

            addressToCoinsPurchased[msg.sender] += packages[_id].coinsAmount;
            totalCoinsSold += packages[_id].coinsAmount;
            emit LogPurchase(msg.sender, msg.value, packages[_id].packageReference);
        }
        
    function _addPackage(uint256 _price, string _packageReference, bool _isActive, uint256 _coinsAmount)
        internal
        {
            require(_price > 0);
            Package memory _package = Package({
            price: uint256(_price),
            packageReference: string(_packageReference),
            isActive: bool(_isActive),
            coinsAmount: uint256(_coinsAmount)
        });

        uint256 newPackageId = packages.push(_package);

        }

    function addPackage(uint256 _price, string _packageReference, bool _isActive, uint256 _coinsAmount)
        external
        onlyOwner
        {
            _addPackage(_price, _packageReference, _isActive, _coinsAmount);
        }
        
    function setPackageActive(uint256 _id, bool _active)
        external
        onlyOwner
        {
            packages[_id].isActive = _active;
        }

    function setPrice(uint256 _packageId, uint256 _newPrice)
        external
        onlyOwner
        {
            require(packages[_packageId].price > 0);
            packages[_packageId].price = _newPrice;
        }

    function getPackage(uint256 _id)
        external 
        view
        returns (uint256 priceInETH, uint256 priceInUSD, string packageReference, uint256 coinsAmount, bool isActive )
        {
            Package storage package = packages[_id];
            priceInETH = priceOf(_id);
            priceInUSD = package.price;
            packageReference = package.packageReference;
            coinsAmount = package.coinsAmount;
            isActive = package.isActive;
        
        }

 
  function priceOf(uint256 _packageId)
    public
    view
    returns (uint256) 
    {

        
        if (medianizer == address(0x0)) {
          return packages[_packageId].price;
        }
        else {
          
          uint256 USDinWei = ChainmonstersMedianizer(medianizer).getUSDPrice();
    
          uint256 multValue = (packages[_packageId].price.mul(multiplier)).div(USDinWei.div(1 ether));
          uint256 inWei = multValue.mul(1 ether);
          uint256 result = inWei.div(shiftValue.mul(multiplier));
          return result;
        }
    
  }
  
  function getPackagesCount()
    public
    view
    returns (uint256)
    {
        return packages.length;
    }

  function setMedianizer(ChainmonstersMedianizer _medianizer)
     public
    onlyOwner 
    {
    require(_medianizer.isMedianizer(), "given address is not a medianizer contract!");
    medianizer = _medianizer;
  }

    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function withdrawBalance()
        external 
        onlyOwner 
        {
            uint256 balance = this.balance;
            owner.transfer(balance);
        }
  
}