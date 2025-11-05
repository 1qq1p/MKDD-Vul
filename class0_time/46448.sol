pragma solidity ^0.4.23;



contract SaddleBasis is  SaddleShopOwner {
    
    
   
    event Birth(address owner, uint256 SaddleId);
   
    event Transfer(address from, address to, uint256 tokenId);

    struct SaddleAttr {
        
        uint256 dna1; 
        uint256 dna2; 
        uint256 dna3;

        bool dna4; 
        
        
    }


    SaddleAttr[] Saddles;

    mapping (uint256 => address) SaddleOwnerIndex;
    
    mapping (uint256 => uint256) public saddleIndexPrice;
    
    mapping (uint256 => uint256) public saddleQuality;
    
    
    
    mapping (uint256 => bool) SaddleIndexForSale;

    mapping (address => uint256) tokenOwnershipCount;
    
    mapping (uint256 => bool)  raceListed;
    
    mapping (uint256 => bool) public DutchAListed;
    
    mapping (uint256 => uint256)  startDutchABlock;
      
    mapping (uint256 => uint256) startDutchAPrice;
    
    mapping (uint256 => uint256) public DutchADecreaseRate;
    
    


  uint256 public saleFee = 20;
   


 
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        tokenOwnershipCount[_to]++;
        SaddleOwnerIndex[_tokenId] = _to;
        
        if (_from != address(0)) {
            tokenOwnershipCount[_from]--;
         
        }
       emit Transfer(_from, _to, _tokenId);
       
    }
    
    
 
    function transfer10( address _to, uint256 _tokenId1, uint256 _tokenId2, uint256 _tokenId3, uint256 _tokenId4, uint256 _tokenId5, uint256 _tokenId6, uint256 _tokenId7, uint256 _tokenId8, uint256 _tokenId9, uint256 _tokenId10  ) external onlyC {
     
       require(_to != address(0));
		
        require(_to != address(this));
     
     require( SaddleOwnerIndex[_tokenId1] == msg.sender );
     require( SaddleOwnerIndex[_tokenId2] == msg.sender );
     require( SaddleOwnerIndex[_tokenId3] == msg.sender );
     require( SaddleOwnerIndex[_tokenId4] == msg.sender );
     require( SaddleOwnerIndex[_tokenId5] == msg.sender );
     require( SaddleOwnerIndex[_tokenId6] == msg.sender );
     require( SaddleOwnerIndex[_tokenId7] == msg.sender );
     require( SaddleOwnerIndex[_tokenId8] == msg.sender );
     require( SaddleOwnerIndex[_tokenId9] == msg.sender );
     require( SaddleOwnerIndex[_tokenId10] == msg.sender );
      
      
      
      _transfer(msg.sender,  _to,  _tokenId1);
        
   
      _transfer(msg.sender,  _to,  _tokenId2);
     
      _transfer(msg.sender,  _to,  _tokenId3);
       
      _transfer(msg.sender,  _to,  _tokenId4);
  
      _transfer(msg.sender,  _to,  _tokenId5);
       
      _transfer(msg.sender,  _to,  _tokenId6);
        
      _transfer(msg.sender,  _to,  _tokenId7);
       
      _transfer(msg.sender,  _to,  _tokenId8);
      
      
      _transfer(msg.sender,  _to,  _tokenId9);
      _transfer(msg.sender,  _to,  _tokenId10);
       
    }
    
    function _sell(address _from,  uint256 _tokenId, uint256 value) internal {
     
           uint256 price;
            
            
         if(DutchAListed[_tokenId]==true){
             
        price  = getCurrentSaddlePrice(_tokenId);
                
         }else{
             
        price  = saddleIndexPrice[_tokenId];
             
         }
         
         if(price==0){
             SaddleIndexForSale[_tokenId]=false;
         }
         
     if(SaddleIndexForSale[_tokenId]==true){
          
            require(price<=value);
            
            
            
         uint256 Fee = price / saleFee /2;
            
          uint256  oPrice= price - Fee - Fee;
            
            address _to = msg.sender;
            
            tokenOwnershipCount[_to]++;
            SaddleOwnerIndex[_tokenId] = _to;
            
            SaddleIndexForSale[_tokenId]=false;
         DutchAListed[_tokenId]=false;
            
            
            if (_from != address(0)) {
                tokenOwnershipCount[_from]--;
               
            }
                 
           emit Transfer(_from, _to, _tokenId);
            
            uint256 saddleQ = saddleQuality[_tokenId]/10;
             address SaddleSOwner;
             
              if(saddleQ>=0&&saddleQ<=2){
              SaddleSOwner= SaddleShopO[5];
                 
             }else  if(saddleQ>=2&&saddleQ<=4){
              SaddleSOwner= SaddleShopO[4];
                 
             } else  if(saddleQ>=4&&saddleQ<=6){
             SaddleSOwner=  SaddleShopO[3];
                 
             } else  if(saddleQ>=6&&saddleQ<=8){
             SaddleSOwner=  SaddleShopO[2];
                 
             }else  if(saddleQ>=8&&saddleQ<=10){
             SaddleSOwner=  SaddleShopO[1];
                 
             }else{
                 
             SaddleSOwner= ceoAddress;
             }
             
            
             
             _from.transfer(oPrice);
             
            uint256 bidExcess = value - oPrice - Fee - Fee;
            _to.transfer(bidExcess);
             
             ceoAddress.transfer(Fee);
             
             if(SaddleSOwner!=0){
                 
             SaddleSOwner.transfer(Fee);
             }else {
             ceoAddress.transfer(Fee);
                 
             }
            
            
     }else{
          _to.transfer(value);
     }
      
    }
    
    
    
    
    
    

      function getCurrentSaddlePrice(uint256 _id) public view returns (uint256)  {
          
      uint256     currentPrice= startDutchAPrice[_id] - DutchADecreaseRate[_id]*(block.number - startDutchABlock[_id]);
  if(currentPrice <=0 ){
      return 0;
  }else if(currentPrice>startDutchAPrice[_id]){
      
      return 0;
  }else{
      
    return currentPrice;
  }
  }
    
      function newDutchPriceRate(uint DecreRate,uint256 _id) external  {
               
               require(msg.sender==SaddleOwnerIndex[_id]);
               
               require(DutchAListed[_id]==true);
               
                DutchADecreaseRate[_id]=DecreRate;
  }
    
    
    
    
       
    function setForDutchSale(uint256 _id, uint256 price, uint256 _decreRate) external {
        
               require(msg.sender==SaddleOwnerIndex[_id]);
        
                 require(raceListed[_id]==false);
                 
        SaddleShopPrice[_id]=price;
        
            
                DutchAListed[_id]=true;
                
                  startDutchABlock[_id] = block.number;
                  
                  startDutchAPrice[_id] = price;
                  
                 DutchADecreaseRate[_id]= _decreRate;
                 
                SaddleIndexForSale[_id]=true;
    }
    
  
    
    
    
    
	
    function _newSaddle(
        uint256 _genes1,
        uint256 _genes2,
        uint256 _genes3,
        bool _genes4,
        address _owner
    )
        internal
        returns (uint)
    {
   
   
   
   
        SaddleAttr memory _saddle = SaddleAttr({
          dna1:_genes1,  
        dna2: _genes2,
        dna3 : _genes3,
        dna4: _genes4
            
        });
       
       
        
       uint256 newSaddleId;
	   
     newSaddleId = Saddles.push(_saddle)-1;
     
  
        require(newSaddleId == uint256(uint32(newSaddleId)));


        
       saddleQuality[newSaddleId]= (_genes1 +_genes2 + _genes3)/3;
        
        raceListed[newSaddleId]=false;
        
       emit Birth(_owner, newSaddleId);

        _transfer(0, _owner, newSaddleId);

        return newSaddleId;  
    }



}

