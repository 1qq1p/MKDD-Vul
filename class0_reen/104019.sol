contract MyTokenShr {
	
    Company public myCompany;
	bool active = false;
	
	modifier onlyActive {if(active) _ }
    modifier onlyfromcompany {if(msg.sender == address(myCompany)) _ }
	
	function initContract(string _name, string _symbol, uint _firstTender, 
						  uint _startPrice )  {
		if(active) throw;
		name = _name;
		symbol =  _symbol;
		myCompany = Company(msg.sender);
		addTender(1,_firstTender, 0, _startPrice);
		active = true;
	}


    
	
	
  	struct Tender { uint id;
                  uint maxstake;
                  uint usedstake;
                  address reservedFor;
                  uint priceOfStake;
  	}
 	Tender[] activeTenders;
  
  	function addTender(uint nid, uint nmaxstake, address nreservedFor,uint _priceOfStake) {

		
    
     	Tender memory newt;
      	newt.id = nid;
      	newt.maxstake = nmaxstake;
      	newt.usedstake = 0;
      	newt.reservedFor = nreservedFor;
      	newt.priceOfStake = _priceOfStake;
      
      	activeTenders.push(newt);
  	}

    function issuetender(address _to, uint tender, uint256 _value) onlyfromcompany {

        for(uint i=0;i<activeTenders.length;i++){
            if(activeTenders[i].id == tender){
                if(activeTenders[i].reservedFor == 0 ||
                    activeTenders[i].reservedFor == _to ){
                        uint stake = _value / activeTenders[i].priceOfStake;
                        if(activeTenders[i].maxstake-activeTenders[i].usedstake >= stake){
                            if (balanceOf[_to] + stake < balanceOf[_to]) throw; 
                            balanceOf[_to] += stake;                            
							totalSupply += stake;
							updateBalance(_to,balanceOf[_to]);
                            Transfer(this, _to, stake); 
                            activeTenders[i].usedstake += stake; 
                            
                        }
                        
                    }
            }
        }
    }
	function destroyToken(address _from, uint _amo) {
		if(balanceOf[_from] < _amo) throw;
		balanceOf[_from] -= _amo;
		updateBalance(_from,balanceOf[_from]);
		totalSupply -= _amo;
 	}
	
	
	uint public pricePerStake = 1;


	function registerEarnings (uint _stake) {

		
		
		
		for(uint i;i<userCnt;i++){
			uint earning = _stake * balanceByID[i].balamce / totalSupply;
			balanceByID[i].earning += earning;
		}
	}
	function queryEarnings(address _addr) returns (uint){
		return balanceByAd[_addr].earning;
	}
	function bookEarnings(address _addr, uint _amo){
		balanceByAd[_addr].earning -=  _amo;
	}

	function setPricePerStake(uint _price)  {
        
        pricePerStake = _price;
    }

	
	
    
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply = 0;

    
    mapping (address => uint256) public balanceOf;



	struct balance {
		uint id;
		address ad;
		uint earning;
		uint balamce;

	}	
	mapping (address  => balance) public balanceByAd;
	mapping (uint => balance) public balanceByID;
	uint userCnt=0;
	
	function updateBalance(address _addr, uint _bal){
		if(balanceByAd[_addr].id == 0){
			userCnt++;
			balanceByAd[_addr] = balance(userCnt, _addr, 0,_bal);
			balanceByID[userCnt] = balanceByAd[_addr];
		} else {
			balanceByAd[_addr].balamce = _bal;
		}
		
	}
	
	
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    

    
    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 

        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                            
		updateBalance(_to,balanceOf[_to]);
		updateBalance(msg.sender,balanceOf[msg.sender]);

        Transfer(msg.sender, _to, _value);                   
    }

    
    function () {
        throw;     
    }
	

}




contract SlotMachine {

	address CompanyAddress = 0;
	
	uint256 maxEinsatz = 1 ether;
	uint256 winFaktor = 2000;
	uint256 maxWin=maxEinsatz * winFaktor;
	uint public minReserve=maxWin ;
	uint public maxReserve=maxWin * 2;
	uint public sollReserve=maxWin+(maxWin * 2 / 10);
	


	
	int earnings = 0;
	uint public gamerun=0;
	uint[4] public wins;

	
	function SlotMachine(){
		
	}
	function setCompany(){
		if(CompanyAddress != 0) throw;
		CompanyAddress=msg.sender; 
	}
	
	
	function closeBooks() {
		if(msg.sender != CompanyAddress) throw; 
		if(earnings <= 0) throw;
		if(this.balance < maxReserve) return;
		uint inc=this.balance-maxReserve;
		bool res = Company(CompanyAddress).send(inc);
	}
	function dumpOut() {
		if(msg.sender != CompanyAddress) throw; 
		bool result = msg.sender.send(this.balance);
	}
	
	uint _nr ;
	uint _y;
	uint _win;
	function(){
		
		if(msg.sender == CompanyAddress) {
			
			return;
		}
		
		
		uint einsatz=msg.value;
		if(einsatz * winFaktor > this.balance) throw; 
		
		
		uint nr = now; 
		uint y = nr & 3;
		
		uint win = 0;
		if(y==0) wins[0]++;
		if(y==1) {wins[1]++; win = (msg.value * 2)  + (msg.value / 2);}
		if(y==2) wins[2]++;
		
		earnings += int(msg.value);

		if(win > 0) { 
			bool res = msg.sender.send(win);
			earnings -= int(win);		
		}
		gamerun++;
		_nr=nr;
		_win=win;
		_y=y;
		
		
		if(this.balance < minReserve){
			Company(CompanyAddress).requestFillUp(sollReserve-this.balance);
		}

	}
	
}








