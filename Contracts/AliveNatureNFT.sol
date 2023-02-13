// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AliveNatureERC721.sol";


// Factory contract for creating NFT contracts
contract NFTFactory {

    // Accounts array
    AliveNatureNFT[] public nftArray;

    //Event to pause
    event AccountPause(uint indexed nftindex, address pauseAccount);
    //Event to unpause
    event AccountUnpause(uint indexed nftindex, address unpauseAccount);
    // Event Safe Mint
    event AccountSafeMint(uint indexed nftindex, address to, address sender);
    // Event Burn
    event AccountBurn(uint indexed nftindex, uint tokenId, address sender);
    //Event create contract
    event CreateAccount(address nft, address owner);

    struct _ProjectData {
        string name;
        uint256 projectTokenId;
        string methodology;
        string region;
        string emissionType;
        string uri;
        address creator;
    }

    struct _RetireData {
        uint256 retireTokenId;
        address beneficiary;
        string  retirementMessage;
        uint256 timeStamp;
        uint256 amount;
    }

 
    function createNFT( uint96 _liquidityPercentage, address _liquidityPoolRecipient, 
        string memory _MyToken, string memory _Symbol, string memory _url) public returns(address) {
        AliveNatureNFT nft = new AliveNatureNFT( _liquidityPercentage, _liquidityPoolRecipient,  _MyToken, _Symbol, _url, msg.sender);    
        nftArray.push(nft);
        emit CreateAccount(address(nft), msg.sender);
        return address(nft);
    }


    // Function to pause the account
    function nftPause(uint256 _nftindex) public {
        nftArray[_nftindex].pause(msg.sender);
        emit AccountPause(_nftindex, msg.sender);
    }

    // Function to unpause the account
    function nftUnpause(uint256 _nftindex) public {
        nftArray[_nftindex].unpause(msg.sender);
        emit AccountUnpause(_nftindex, msg.sender);
    }

    function nftSafeMint(uint256 _nftindex, address _to, string memory _uri, string memory _name,
        string memory _methodology, string memory _region, string memory _emissionType) public {
        nftArray[_nftindex].safeMint(_to, _uri, _name, _methodology, _region,
        _emissionType, msg.sender);
        emit AccountSafeMint(_nftindex, _to, msg.sender);
    }

    function nftBurn(uint256 _nftindex, uint256 _tokenId, string memory _retirementMessage, uint256 _amount) public {
        nftArray[_nftindex].burnToken(_tokenId, _retirementMessage, _amount, msg.sender);
        emit AccountBurn(_nftindex, _tokenId, msg.sender);
    }

    function nftUpdateValues(uint256 _nftindex, uint96 _liquidityPercentage, address _liquidityPoolRecipient) public {
        nftArray[_nftindex].updateValues(_liquidityPercentage, _liquidityPoolRecipient, msg.sender);
    }

    function nftUpdateComission(uint256 _nftindex, uint96 _commissionPercentage, address _commissionRecipient) public {
        nftArray[_nftindex].updateComission(_commissionPercentage, _commissionRecipient, msg.sender);
    }


    function getNftOwnerOf(uint256 _nftindex, uint256 _tokenId) public view returns (address) {
        return nftArray[_nftindex].ownerOf(_tokenId);
    }


    function getNftProjectData(uint256 _nftindex, uint256 tokenId) public view returns (_ProjectData memory) {
        AliveNatureNFT.ProjectData memory projectData = nftArray[_nftindex].getProjectData(tokenId);
        _ProjectData memory returnedData;

        returnedData.uri = projectData.uri;
        returnedData.name = projectData.name;
        returnedData.methodology = projectData.methodology;
        returnedData.region = projectData.region;
        returnedData.emissionType = projectData.emissionType;
        returnedData.creator = projectData.creator;

        return returnedData;
    }

    function getNftRetireData(uint256 _nftindex, uint256 tokenId) public view returns (_RetireData memory) {
        AliveNatureNFT.RetireData memory retireData = nftArray[_nftindex].getRetireData(tokenId);
        _RetireData memory returnedData;

        returnedData.retireTokenId = retireData.retireTokenId;
        returnedData.beneficiary = retireData.beneficiary;
        returnedData.retirementMessage = retireData.retirementMessage;
        returnedData.timeStamp = retireData.timeStamp;
        returnedData.amount = retireData.amount;

        return returnedData;
    }


    function getNftCommissionPercentage(uint256 _nftindex) public view returns (uint96) {
        return nftArray[_nftindex].getCommissionPercentage();
    }

    function getNftLiquidityPercentage(uint256 _nftindex) public view returns (uint96) {
        return nftArray[_nftindex].getLiquidityPercentage();
    }

    function getNftCommissionRecipient(uint256 _nftindex) public view returns (address) {
        return nftArray[_nftindex].getCommissionRecipient();
    }

    function getNftLiquidityPoolRecipient(uint256 _nftindex) public view returns (address) {
        return nftArray[_nftindex].getLiquidityPoolRecipient();
    }

    function getNftIndexFromAddress(address _nftAddress) public view returns (uint) {
    for (uint i = 0; i < nftArray.length; i++) {
        if (address(nftArray[i]) == _nftAddress) {
            return i;
        }
    }
    return uint(0);
}


}


