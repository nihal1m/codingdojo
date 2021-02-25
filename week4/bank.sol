//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./BankInterface.sol" ;

import "../github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";



contract bankOfDojo is BankInterface, ERC20 {

    mapping(address => uint256) private balance;
    
    address public owner;
    address payable public coOwner;
    
    constructor () public ERC20("PepsiToken", "diet"){
        owner = payable(msg.sender);
 
    }
    
    modifier onlyOwner {
        require(msg.sender == owner  , "only owner allows to run this function");
        _;
    }
    
    
    // store the address in the struct
    function deposit() public override payable {
        require(balance[msg.sender] + msg.value >= balance[msg.sender]);
        balance[msg.sender] += msg.value;
        
    }
    
    function balances() public override view returns(uint256){
        return balance[msg.sender];
    }
    
    function withdraw(uint256 amount) public override payable returns(uint256 ) {
      
      require(balance[msg.sender] >= amount);
      balance[msg.sender] -= amount;
      payable(msg.sender).transfer(amount);
      
      return balance[msg.sender];
    }
    
    
//     function close() public override  onlyOwner {
// 		selfdestruct(address(uint160(owner)));
// 	}
    
    
    
} 
