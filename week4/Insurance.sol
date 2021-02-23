// I'm working on it , to fix the problems .


//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.1;

/**
 * @title Tech Insurance tor
 * @dev 
 * Step1: Complete the functions in the insurance smart contract
 * Step2:Add any required methods that are needed to check if the function are called correctly, 
 * and also add a modifier function that allows only the owner can run the changePrice function.
 * Step3: Add any error handling that may occur in any function
 * Step 4: add ERC 721 Token
 * 
 */
contract TechInsurance {
    
    /** 
     * Defined two structs
     * 
     * 
     */
    struct Product {
        uint productId;
        string productName;
        uint price;
        bool offered;
        uint newPrice;
    }
     
    struct Client {
        bool isValid;
        uint time;
    }
    
    
    mapping(uint => Product) public productIndex;
    mapping(address => mapping(uint => Client)) public client;
    
    uint productCounter;
    
    address payable insOwner;
    constructor(address payable _insOwner) public{
        insOwner = _insOwner;
    }
 
    function addProduct(uint _productId, string memory _productName, uint _price ) public {
        Product memory newProduct;
        productIndex[msg.sender] = Product(_productId, _productName, _price,true);
        productIndex[productCounter++]= newProduct;
            
    }
    
    
    function changeFalse(uint _productIndex) public view  {
        require(productIndex[_productIndex].offered == false, "the Product is offered");
        require(msg.Product == productIndex[_productIndex].offered);
        return false;
       
        
    }
    
    function changeTrue(uint _productIndex) public view  {
        require(productIndex[_productIndex].offered != true, "the Product is not offered");
        require(msg.Product != productIndex[_productIndex].offered);

    }
    
    modifier onlyOwner(uint) {
        require(
            msg.sender == onlyOwner,
            "Only owner can call this function."
        );
    
    function changePrice(uint _productIndex, uint _price) public onlyOwner {
     price = _price;
     return newPrice;
        
    }
    
    function clientSelect(uint _productIndex) public payable {
        require(msg.address == productIndex[_productIndex].time,"check the time"
        productIndex[_productIndex].isValid=true;
    } 
    
}
