pragma solidity ^0.4.16;
contract TocIcoData{


 

address Mars = 0x1947f347B6ECf1C3D7e1A58E3CDB2A15639D48Be;
address Mercury = 0x00795263bdca13104309Db70c11E8404f81576BE;
address Europa = 0x00e4E3eac5b520BCa1030709a5f6f3dC8B9e1C37;
address Jupiter = 0x2C76F260707672e240DC639e5C9C62efAfB59867;
address Neptune = 0xEB04E1545a488A5018d2b5844F564135211d3696;


function GetContractAddr() public constant returns (address){
return this;
}	
address ContractAddr = GetContractAddr();

struct State{
bool Suspend;    
bool PrivateSale;
bool PreSale;
bool MainSale; 
bool End;
}

struct Market{
uint256 EtherPrice;    
uint256 TocPrice;    
} 

struct Admin{
bool Authorised; 
uint256 Level;
}


mapping (address => State) public state;

mapping (address => Market) public market;

mapping (address => Admin) public admin;


function AuthAdmin(address _admin, bool _authority, uint256 _level) external 
returns(bool) {
if((msg.sender != Mars) && (msg.sender != Mercury) && (msg.sender != Europa)
&& (msg.sender != Jupiter) && (msg.sender != Neptune)) revert();  
admin[_admin].Authorised = _authority; 
admin[_admin].Level = _level;
return true;
} 


function GeneralUpdate(uint256 _etherprice, uint256 _tocprice) external returns(bool){
    
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();

market[ContractAddr].EtherPrice = _etherprice; 
market[ContractAddr].TocPrice = _tocprice;
return true;
}


function EtherPriceUpdate(uint256 _etherprice)external returns(bool){
    
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();

market[ContractAddr].EtherPrice = _etherprice; 
return true;
}


function UpdateState(uint256 _state) external returns(bool){
    
if(admin[msg.sender].Authorised == false) revert();
if(admin[msg.sender].Level < 5 ) revert();

if(_state == 1){
state[ContractAddr].Suspend = true;     
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = false;
}

if(_state == 2){
state[ContractAddr].Suspend = false;     
state[ContractAddr].PrivateSale = true; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = false;
}

if(_state == 3){
state[ContractAddr].Suspend = false;    
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = true;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = false;
}

if(_state == 4){
state[ContractAddr].Suspend = false;    
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = true;
state[ContractAddr].End = false;
}

if(_state == 5){
state[ContractAddr].Suspend = false;    
state[ContractAddr].PrivateSale = false; 
state[ContractAddr].PreSale = false;
state[ContractAddr].MainSale = false;
state[ContractAddr].End = true;
}
return true;
}




function GetSuspend() public view returns (bool){
return state[ContractAddr].Suspend;
}

function GetPrivateSale() public view returns (bool){
return state[ContractAddr].PrivateSale;
}

function GetPreSale() public view returns (bool){
return state[ContractAddr].PreSale;
}

function GetMainSale() public view returns (bool){
return state[ContractAddr].MainSale;
}

function GetEnd() public view returns (bool){
return state[ContractAddr].End;
}

function GetEtherPrice() public view returns (uint256){
return market[ContractAddr].EtherPrice;
}

function GetTocPrice() public view returns (uint256){
return market[ContractAddr].TocPrice;
}

}


pragma solidity ^0.4.16;