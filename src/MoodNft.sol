// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; 


import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Base64} from "lib/openzeppelin-contracts/contracts/utils/Base64.sol";


contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner();

     uint256 private s_tokenCounter;
     string private s_happySvgImageUri;
     string private s_sadSvgImageUri;

     enum NFTState {
        HAPPY,
        SAD
     }
    mapping (uint256 => NFTState) private s_tokenIdToState;

     constructor (
        string memory happySvgImageUri,
        string memory sadSvgImageUri
     ) ERC721 ("Mood NFT", "MN"){
        s_happySvgImageUri = happySvgImageUri;
        s_sadSvgImageUri = sadSvgImageUri;
        s_tokenCounter = 0; 
     }

    function mintNft () public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToState[s_tokenCounter] = NFTState.HAPPY;
        s_tokenCounter++;
    }

    function flipMood (uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender){
             revert MoodNft__CantFlipMoodIfNotOwner();
        }
        if (s_tokenIdToState[tokenId] == NFTState.HAPPY){
             s_tokenIdToState[tokenId] = NFTState.SAD;
        }else{
              s_tokenIdToState[tokenId] = NFTState.HAPPY;
        }
    }

     function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    } 

     function tokenURI(
        uint256 tokenId
    ) public view virtual override returns ( string memory) {
         string memory imageURI = s_happySvgImageUri;

        if (s_tokenIdToState[tokenId] == NFTState.SAD) {
            imageURI = s_sadSvgImageUri;
        }
           return string (
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}],  "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    } 
     

     function getNftState (uint256 tokenId) public view returns (NFTState) {
         return s_tokenIdToState[tokenId];
     }

}