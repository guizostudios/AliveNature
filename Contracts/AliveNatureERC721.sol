// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract AliveNatureNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC2981, Pausable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // percentage split for commission and liquidity pool
    uint96 public royaltyPercentage;
    uint96 public commissionPercentage;
    uint96 public liquidityPercentage;

    // address of the royalty recipient
    address public royaltyRecipient;
    // address of the commission recipient
    address public commissionRecipient;
    // address of the liquidity pool
    address public liquidityPoolRecipient;
    // Owner address
    address public ownerNFT;

    //Base URI
    string private url;

    struct ProjectData {
        string name;
        uint256 projectTokenId;
        string methodology;
        string region;
        string emissionType;
        string uri;
        address creator;
    }

    struct RetireData {
        uint256 retireTokenId;
        address beneficiary;
        string retirementMessage;
        uint256 timeStamp;
        uint256 amount;
    }

    mapping (uint256 => ProjectData) private _projectData;
    mapping (uint256 => RetireData) private _retireData;


    modifier onlyOwner {
        require(msg.sender == ownerNFT, "Only the owner can call this function");
         _;
    }

    modifier onlyAdmin {
        require(msg.sender == commissionRecipient, "Only the heir can call this function");
         _;
    }



    constructor( string memory _MyToken, string memory _Symbol) ERC721(_MyToken, _Symbol) {

        commissionPercentage = 350;
        liquidityPercentage = 0;
        royaltyPercentage = 0;

        commissionRecipient = 0xE3506A38C80D8bA1ef219ADF55E31E18FB88EbF4;
        liquidityPoolRecipient = msg.sender;
        royaltyRecipient = msg.sender;
        ownerNFT = msg.sender;

        _setDefaultRoyalty(commissionRecipient, commissionPercentage);


    }

    function _baseURI() internal view override returns (string memory) {
        return url;
    }

    function pause() external onlyAdmin  {
        _pause();
    }

    function unpause() external onlyAdmin() {
        _unpause();
    }


    function safeMint(address _to, string memory _uri, string memory _name,
    string memory _methodology, string memory _region,  string memory _emissionType) public whenNotPaused onlyOwner() {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _uri);
        
        // Create a new ProjectData struct and store it in the contract's storage
        _projectData[tokenId] = ProjectData({
        projectTokenId : tokenId,
        uri : _uri,
        name : _name,
        methodology : _methodology,
        region : _region,
        emissionType : _emissionType,
        creator : msg.sender
        });
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
            if (from != address(0)) {
            address owner = ownerOf(tokenId);
            require(owner == msg.sender, "Only the owner of NFT can transfer or burn it");
        }
    }

    function _burn(uint256 tokenId) internal whenNotPaused override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function burnToken(uint256 tokenId, string memory _retirementMessage, uint256 _amount) public whenNotPaused onlyOwner{
        address owner = ownerOf(tokenId);
        require(owner == msg.sender, "Only the owner of NFT can burn it");
        _burn(tokenId);

        // Create a new ProjectData struct and store it in the contract's storage
        _retireData[tokenId] = RetireData({
        retireTokenId : tokenId,
        beneficiary : msg.sender,
        retirementMessage : _retirementMessage,
        timeStamp : block.timestamp,
        amount : _amount
        });
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

 
    function updateValues( uint96 _liquidityPercentage, uint96 _royaltyPercentage, address _liquidityPoolRecipient, address _royaltyRecipient) public  onlyOwner{

         liquidityPercentage = _liquidityPercentage;
         royaltyPercentage = _royaltyPercentage;
         liquidityPoolRecipient = _liquidityPoolRecipient;
         royaltyRecipient = _royaltyRecipient;
    }

    function updateComission( uint96 _commissionPercentage, address _commissionRecipient) public  onlyAdmin {
        commissionPercentage = _commissionPercentage;
        commissionRecipient = _commissionRecipient;
        _setDefaultRoyalty(commissionRecipient, commissionPercentage);
    }


    function ownerOf(uint256 tokenId) public view virtual override(ERC721, IERC721) returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function getProjectData(uint256 tokenId) public view returns (ProjectData memory) {
        return _projectData[tokenId];
    }

    function getRetireData(uint256 tokenId) public view returns (RetireData memory) {
        return _retireData[tokenId];
    }


    function getCommissionPercentage() public view returns (uint96) {
        return commissionPercentage;
    }

    function getLiquidityPercentage() public view returns (uint96) {
        return liquidityPercentage;
    }


    function getRoyaltyPercentage() public view returns (uint96) {
        return royaltyPercentage;
    }

    function getRoyaltyRecipient() public view returns (address) {
        return royaltyRecipient;
    }

    function getCommissionRecipient() public view returns (address) {
        return commissionRecipient;
    }

    function getLiquidityPoolRecipient() public view returns (address) {
        return liquidityPoolRecipient;
    }

}



