// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AliveNatureNFT.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract AliveNatureMarketplace is Pausable, Ownable, ReentrancyGuard  {
    using Counters for Counters.Counter;
    
    Counters.Counter private numOfListing;

struct NFTListing {  
  ERC721 nft;
  uint tokenId;
  uint price;
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

  
// this function will list an artifact into the marketplace
  function listNFT(ERC721 _nft,  uint256 _tokenId, uint256 _price) external {
    require(_price > 0, "NFTMarket: price must be greater than 0");
    numOfListing.increment();
    listings[numOfListing.current()] = NFTListing(
       _nft,
       _tokenId,
       _price,
       payable(msg.sender), 
       false
       );
  }


// this function will cancel the listing. it also has checks to make sure only the owner of the listing can cancel the listing from the market place
function sell(uint256 _Id) external onlyNftOwner(_Id){
     NFTListing storage listing = listings[_Id];
     require(listing.seller == msg.sender, "Only the nft owner can sell nft");
     require(listing.forSale == false);
     listing.nft.transferFrom(msg.sender, address(this), _Id);
     listing.forSale = true;
  }


  function cancel(uint _Id) external onlyNftOwner(_Id){
     NFTListing storage listing = listings[_Id];
     require(listing.seller == msg.sender);
     require(listing.forSale == true);
     listing.nft.transferFrom(address(this), msg.sender, _Id);
     listing.forSale = false;
  }



// this function will facilitate the purchasing of a listing
  function buyNFT(uint _Id, uint96 _royaltyPercentage, uint96 _liquidityPercentage, uint96 _stakingPercentage, 
  address _royaltyRecipient,address _liquidityPoolRecipient, address _stakingRecipient) public payable whenNotPaused nonReentrant {
        NFTListing storage listing = listings[_Id];
        require(_Id > 0 && _Id <= numOfListing.current(), "item doesn't exist");
        require(msg.value >= listing.price,"not enough balance for this transaction");
        require(listing.forSale != false, "item is not for sell");
        require(listing.seller != msg.sender, "You cannot buy your own nft");

        uint256 royaltyAmount = SafeMath.mul(listing.price, _royaltyPercentage);
        royaltyAmount = SafeMath.div(royaltyAmount, 10000);
        uint256 liquidityAmount = SafeMath.mul(listing.price, _liquidityPercentage);
        liquidityAmount = SafeMath.div(liquidityAmount, 10000);
        uint256 stakingAmount = SafeMath.mul(listing.price, _stakingPercentage);
        stakingAmount = SafeMath.div(stakingAmount, 10000);
        uint256 price1 = SafeMath.sub(listing.price, royaltyAmount);
        uint256 price2 = SafeMath.sub(price1, liquidityAmount);
        uint256 finalPrice = SafeMath.sub(price2, stakingAmount);


        payable(_royaltyRecipient).transfer(royaltyAmount);
        payable(_liquidityPoolRecipient).transfer(liquidityAmount);
        payable(_stakingRecipient).transfer(stakingAmount);
        payable(listing.seller).transfer(finalPrice);

        listing.nft.transferFrom(address(this), msg.sender, listing.tokenId);
        listing.seller = msg.sender;
        listing.forSale = false;
    }


//        require(_isApprovedOrOwner(seller, _tokenId), "Token is not owned or approved by the seller.");
  //      require(getApproved(_tokenId) == msg.sender, "Seller has not approved the transfer of the token.");



// this function will get the listings in the market place
    function getNFTListing(uint _Id) public view returns (NFTListing memory) {
        return listings[_Id];
    }

    
    // get list of items
    function getListinglength() public view returns (uint) {
        return numOfListing.current();
    }   
}