pragma solidity ^0.4.21;






contract StrikersPlayerList is Ownable {
  
  
  
  
  
  
  
  
  
  

  
  event PlayerAdded(uint8 indexed id, string name);

  
  
  uint8 public playerCount;

  
  
  
  
  constructor() public {
    addPlayer("Lionel Messi"); 
    addPlayer("Cristiano Ronaldo"); 
    addPlayer("Neymar"); 
    addPlayer("Mohamed Salah"); 
    addPlayer("Robert Lewandowski"); 
    addPlayer("Kevin De Bruyne"); 
    addPlayer("Luka Modrić"); 
    addPlayer("Eden Hazard"); 
    addPlayer("Sergio Ramos"); 
    addPlayer("Toni Kroos"); 
    addPlayer("Luis Suárez"); 
    addPlayer("Harry Kane"); 
    addPlayer("Sergio Agüero"); 
    addPlayer("Kylian Mbappé"); 
    addPlayer("Gonzalo Higuaín"); 
    addPlayer("David de Gea"); 
    addPlayer("Antoine Griezmann"); 
    addPlayer("N'Golo Kanté"); 
    addPlayer("Edinson Cavani"); 
    addPlayer("Paul Pogba"); 
    addPlayer("Isco"); 
    addPlayer("Marcelo"); 
    addPlayer("Manuel Neuer"); 
    addPlayer("Dries Mertens"); 
    addPlayer("James Rodríguez"); 
    addPlayer("Paulo Dybala"); 
    addPlayer("Christian Eriksen"); 
    addPlayer("David Silva"); 
    addPlayer("Gabriel Jesus"); 
    addPlayer("Thiago"); 
    addPlayer("Thibaut Courtois"); 
    addPlayer("Philippe Coutinho"); 
    addPlayer("Andrés Iniesta"); 
    addPlayer("Casemiro"); 
    addPlayer("Romelu Lukaku"); 
    addPlayer("Gerard Piqué"); 
    addPlayer("Mats Hummels"); 
    addPlayer("Diego Godín"); 
    addPlayer("Mesut Özil"); 
    addPlayer("Son Heung-min"); 
    addPlayer("Raheem Sterling"); 
    addPlayer("Hugo Lloris"); 
    addPlayer("Radamel Falcao"); 
    addPlayer("Ivan Rakitić"); 
    addPlayer("Leroy Sané"); 
    addPlayer("Roberto Firmino"); 
    addPlayer("Sadio Mané"); 
    addPlayer("Thomas Müller"); 
    addPlayer("Dele Alli"); 
    addPlayer("Keylor Navas"); 
    addPlayer("Thiago Silva"); 
    addPlayer("Raphaël Varane"); 
    addPlayer("Ángel Di María"); 
    addPlayer("Jordi Alba"); 
    addPlayer("Medhi Benatia"); 
    addPlayer("Timo Werner"); 
    addPlayer("Gylfi Sigurðsson"); 
    addPlayer("Nemanja Matić"); 
    addPlayer("Kalidou Koulibaly"); 
    addPlayer("Bernardo Silva"); 
    addPlayer("Vincent Kompany"); 
    addPlayer("João Moutinho"); 
    addPlayer("Toby Alderweireld"); 
    addPlayer("Emil Forsberg"); 
    addPlayer("Mario Mandžukić"); 
    addPlayer("Sergej Milinković-Savić"); 
    addPlayer("Shinji Kagawa"); 
    addPlayer("Granit Xhaka"); 
    addPlayer("Andreas Christensen"); 
    addPlayer("Piotr Zieliński"); 
    addPlayer("Fyodor Smolov"); 
    addPlayer("Xherdan Shaqiri"); 
    addPlayer("Marcus Rashford"); 
    addPlayer("Javier Hernández"); 
    addPlayer("Hirving Lozano"); 
    addPlayer("Hakim Ziyech"); 
    addPlayer("Victor Moses"); 
    addPlayer("Jefferson Farfán"); 
    addPlayer("Mohamed Elneny"); 
    addPlayer("Marcus Berg"); 
    addPlayer("Guillermo Ochoa"); 
    addPlayer("Igor Akinfeev"); 
    addPlayer("Sardar Azmoun"); 
    addPlayer("Christian Cueva"); 
    addPlayer("Wahbi Khazri"); 
    addPlayer("Keisuke Honda"); 
    addPlayer("Tim Cahill"); 
    addPlayer("John Obi Mikel"); 
    addPlayer("Ki Sung-yueng"); 
    addPlayer("Bryan Ruiz"); 
    addPlayer("Maya Yoshida"); 
    addPlayer("Nawaf Al Abed"); 
    addPlayer("Lee Chung-yong"); 
    addPlayer("Gabriel Gómez"); 
    addPlayer("Naïm Sliti"); 
    addPlayer("Reza Ghoochannejhad"); 
    addPlayer("Mile Jedinak"); 
    addPlayer("Mohammad Al-Sahlawi"); 
    addPlayer("Aron Gunnarsson"); 
    addPlayer("Blas Pérez"); 
    addPlayer("Dani Alves"); 
    addPlayer("Zlatan Ibrahimović"); 
  }

  
  
  function addPlayer(string _name) public onlyOwner {
    require(playerCount < 255, "You've already added the maximum amount of players.");
    emit PlayerAdded(playerCount, _name);
    playerCount++;
  }
}



