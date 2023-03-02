// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract AliveNatureMarketplace is Ownable, Pausable,  ReentrancyGuard  {
    IERC20 public ERC20;
    IERC721 public ERCNFT;

    using Counters for Counters.Counter;
    
    Counters.Counter private numOfListing;



struct NFTListing {  
  ERC721 nft;
  uint tokenId;
  uint price;
  address coin;
  address seller;
  bool forSale;
}
  
 
  mapping(uint256 => NFTListing) public listings;
   
   modifier onlyNftOwner(uint _Id) {
        require(msg.sender == listings[_Id].seller);
        _;
    }


    function pauseMarketplace() public onlyOwner {
        _pause();
    }

    function unpauseMarketplace() public onlyOwner {
        _unpause();
    }

  
// this function will list and sell an NFT into the marketplace
  function listNFT(ERC721 _nft,  uint256 _tokenId, uint256 _price, address _coin) external {
    require (ERCNFT.ownerOf(_tokenId) == msg.sender, "You are not the owner");
    require(_price > 0, "NFTMarket: price must be greater than 0");
    numOfListing.increment();
    listings[numOfListing.current()] = NFTListing(
       _nft,
       _tokenId,
       _price,
       _coin,
       payable(msg.sender), 
       false
       );
    NFTListing storage listing = listings[_tokenId];
    listing.nft.transferFrom(msg.sender, address(this), _tokenId);
    listing.forSale = true;

  }

// this function will cancel the listing. it also has checks to make sure only the owner of the listing can cancel the listing from the market place

  function cancel(uint _Id) external onlyNftOwner(_Id){
     NFTListing storage listing = listings[_Id];
     require(listing.seller == msg.sender);
     require(listing.forSale == true);
     listing.nft.transferFrom(address(this), msg.sender, _Id);
     listing.forSale = false;
  }



// this function will facilitate the purchasing of a listing
  function buyNFT(uint _Id) public payable whenNotPaused nonReentrant {
        NFTListing storage listing = listings[_Id];
        require(_Id > 0 && _Id <= numOfListing.current(), "item doesn't exist");
        require(msg.value >= listing.price,"not enough balance for this transaction");
        require(listing.forSale != false, "item is not for sell");
        require(listing.seller != msg.sender, "You cannot buy your own nft");

        uint256 comissionAmount = SafeMath.mul(listing.price, 350);
        comissionAmount = SafeMath.div(comissionAmount, 10000);
        uint256 sellerAmount = SafeMath.sub(listing.price, comissionAmount);


        if (listing.coin == 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9){
        require(sellerAmount <= address(this).balance, "Insufficient funds.");
        payable(listing.seller).transfer(sellerAmount);
        } else {
          ERC20 = IERC20(listing.coin);
          require(sellerAmount <= ERC20.balanceOf(address(this)), "Insufficient funds.");
          ERC20.transfer(listing.seller, sellerAmount);

        }
        listing.nft.transferFrom(address(this), msg.sender, listing.tokenId);
        listing.seller = msg.sender;
        listing.forSale = false;
    }


// this function will get the listings in the market place
    function getNFTListing(uint _Id) public view returns (NFTListing memory) {
        return listings[_Id];
    }

    
    // get list of items
    function getListinglength() public view returns (uint) {
        return numOfListing.current();
    }   

}