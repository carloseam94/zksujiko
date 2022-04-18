//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

// Import the OpenZeppeling Contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

interface IVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[13] memory input
    ) external view returns (bool);
}

// Inherit the OpenZeppeling contract to create robust contracts
contract Sujiko is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    Counters.Counter private boardsCounter;

    struct sujikoStruct {
       uint256[9] board;
       uint256[4] circles;
    }

    address public verifierAddr;
    uint256 public limitBoards;
    sujikoStruct[32] boards;

    // Black svg with white text over it
    string svg1 = '<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg"><rect width="100%" height="100%"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="fill:#fff;font-family:sans;font-size:30px">';
    string svg2 = "</text></svg>";

    // Notify the frontend whenever a new NFT is succesfully minted
    event NewNFTMinted(address sender, uint256 tokenId);

    // Constructor following ERC721 protocol (name and symbol)
    constructor(address _verifierAddr) ERC721("Sujiko", "SUJIKO") {
        verifierAddr = _verifierAddr;
        limitBoards = 32;
        boards[boardsCounter.current()] = sujikoStruct([uint256(0), 0, 0, 0, 0, 0, 8, 0, 7],[uint256(10), 21, 18, 20]);
        boardsCounter.increment();
    }

    function random() public view returns (uint256) {
        return uint256(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % (boardsCounter.current()));
    } 

    function getNewBoard(uint256 _i) public view returns (uint256[9] memory, uint256[4] memory, uint256) {
        require(_i >= 0 && _i < boardsCounter.current(), "Error: Invalid board index");
        return (boards[_i].board, boards[_i].circles, boardsCounter.current());
    }

    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[13] memory input
    ) public view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }

    function verifySujiko(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[13] memory input
    ) public view returns (bool) {
        require(verifyProof(a, b, c, input), "Error in verify proof");
        require(!isNewSujiko(input), "Error: Unknown Sujiko");
        return true;
    }

     function contributeSujiko(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[13] memory input
    ) public returns (bool) {
        require(verifyProof(a, b, c, input), "Error in verify proof");
        require(isNewSujiko(input), "Error: Sujiko already exist");
        require(contributeWithBoard(input));
        return true;
    }

    function isNewSujiko(uint256[13] memory _sujiko) public view returns (bool) {
        uint256 currentBoardsCounter = boardsCounter.current();
        for (uint256 i = 0; i < currentBoardsCounter; i++) {
            bool isEqual = true;
            for (uint256 j = 0; j < 9; j++) {
                isEqual = isEqual && boards[i].board[j] == _sujiko[j];
            }
            for (uint256 j = 0; j < 4; j++) {
                isEqual = isEqual && boards[i].circles[j] == _sujiko[9 + j];
            }
            if(isEqual) {
                return false;
            }
        }
        return true;
    }

    function contributeWithBoard(uint256[13] memory _sujiko) public returns (bool) {
        require(boardsCounter.current() < limitBoards, "Error: Reached limit of sujikos");
        sujikoStruct memory newSujiko = sujikoStruct([uint256(0),0,0,0,0,0,0,0,0], [uint256(0),0,0,0]);
        for (uint256 i = 0; i < 9; i++) {
            newSujiko.board[i] = _sujiko[i];
        }
        for (uint256 i = 9; i < 13; i++) {
            newSujiko.circles[i - 9] = _sujiko[i];
        }
        boards[boardsCounter.current()] = newSujiko;
        boardsCounter.increment();
        return true;
    }

    // Function to build and mint the NFT
    function mintNFT(address personAddress) public {

        uint256 newItemId = _tokenIds.current();

        string memory svg3 = string(abi.encodePacked(svg1, "Thanks for the contribution!", svg2));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', "Sujiko Solved",
                        '", "description": "This NFT certifies that you have contributed with your own Sujiko", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg3)),
                        '"}'
                    )
                )
            )
        );

        string memory tokenUri = string(abi.encodePacked("data:application/json;base64,", json));
        
        // Mint and update the URI
        _safeMint(personAddress, newItemId);
        _setTokenURI(newItemId, tokenUri);

        // Increment the counter when the next NFT is minted.
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, personAddress);

    }
}
