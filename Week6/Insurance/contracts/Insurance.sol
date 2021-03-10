
//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.1;

//import "github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
contract Insurance {
    

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // Mapping from token ID to owner address
    mapping (uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping (address => uint256) private _balances;
    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    
        function ownerOf(uint256 tokenId) public view virtual  returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
        function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    
        function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    struct Product {
        uint productId;
        string productName;
        uint price;
        bool offered;
    }
     
    struct Client {
        bool isValid;
        uint time;
    }
    
     modifier OnlyinsOwner(uint _prodID) {
         require(msg.sender == ownerOf(_prodID));
         _;
    }
         modifier TimeCheck {
         require(block.timestamp <= timeLocked + 15 minutes );
         _;
     }
    
    mapping(uint => Product) public productIndex;
    mapping(address => mapping(uint => Client)) public client;
    uint256 timeLocked = block.timestamp;
    uint productCounter;
    
     address payable insOwner;
    // constructor(address payable _insOwner) public{
    //     insOwner = _insOwner;
    // }
 
    function addProduct(uint _productId, string memory _productName, uint _price ) public  {
        
       productCounter++;
       address  prodOwner = msg.sender;
       productIndex[productCounter]= Product(_productId, _productName, _price, true);
       _mint(prodOwner, productCounter);
    }
    
    
    function doNotOffer(uint _productIndex) public {
        require(msg.sender == insOwner,"No Offer");
        productIndex[_productIndex].offered = false;
    }
    
    function forOffer(uint _productIndex) public OnlyinsOwner(_productIndex) {
        require(msg.sender == insOwner,"Yes Offer");
        productIndex[_productIndex].offered = true;
    }
    
    function changePrice(uint _productIndex, uint _price) public OnlyinsOwner(_productIndex) {
        require( productIndex[_productIndex].price>=1);
        productIndex[_productIndex].price = _price;
        
    }
    
    
    function buyInsurance(uint _productIndex) public payable TimeCheck {
        require(productIndex[_productIndex].offered == true, "This item is sold out!");
        require(msg.value <= productIndex[_productIndex].price, "You don't have enough tokens!");
        doNotOffer(_productIndex);        
        Client(true, block.timestamp);
        _transfer(ownerOf(_productIndex), msg.sender,_productIndex);   
        doNotOffer(_productIndex);   
    } 
    
}
