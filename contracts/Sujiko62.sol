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
        uint256[20] memory input
    ) external view returns (bool);
}

contract Sujiko62 is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    Counters.Counter private sujikosCounter;

    struct sujiko62Struct {
       uint256[6] squares;
       uint256[2] circles;
       uint256[6][2] edges;
    }

    address public verifierAddr;
    uint256 public limitSujikos;
    sujiko62Struct[32] sujikos;

    // Black svg with white text over it
    string svg1 = '<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg"><rect width="100%" height="100%"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="fill:#fff;font-family:sans;font-size:30px">';
    string svg2 = "</text></svg>";

    // Constructor following ERC721 protocol (name and symbol)
    constructor(address _verifierAddr) ERC721("Sujiko62", "SUJIKO62") {
        verifierAddr = _verifierAddr;
        limitSujikos = 32;
        sujikos[sujikosCounter.current()] = sujiko62Struct([uint256(1), 0, 0, 0, 5, 0],[uint256(10), 15], [[uint256(1),1,1,1,0,0],[uint256(0),0,0,1,1,1]]);
        sujikosCounter.increment();
    }

    function random() public view returns (uint256) {
        return uint256(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % (sujikosCounter.current()));
    } 

    function getNewSujiko62(uint256 _i) public view returns (uint256[6] memory, uint256[2] memory, uint256[6][2] memory, uint256) {
        require(_i >= 0 && _i < sujikosCounter.current(), "Error: Invalid sujikos index");
        return (sujikos[_i].squares, sujikos[_i].circles, sujikos[_i].edges, sujikosCounter.current());
    }

    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[20] memory input
    ) public view returns (bool) {
        return IVerifier(verifierAddr).verifyProof(a, b, c, input);
    }

    function verifySujiko62(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[20] memory input
    ) public view returns (bool) {
        require(verifyProof(a, b, c, input), "Error in verify proof");
        require(!isNewSujiko62(input), "Error: Unknown Sujiko62");
        return true;
    }

     function contributeSujiko62(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[20] memory input
    ) public returns (bool) {
        require(verifyProof(a, b, c, input), "Error in verify proof");
        require(isNewSujiko62(input), "Error: Sujiko62 already exist");
        require(contributeWithSujiko62(input));
        return true;
    }

    function isNewSujiko62(uint256[20] memory _sujiko) public view returns (bool) {
        uint256 currentSujikosCounter = sujikosCounter.current();
        for (uint256 i = 0; i < currentSujikosCounter; i++) {
            bool isEqual = true;
            for (uint256 j = 0; j < 6; j++) {
                isEqual = isEqual && sujikos[i].squares[j] == _sujiko[j];
            }
            for (uint256 j = 6; j < 8; j++) {
                isEqual = isEqual && sujikos[i].circles[j-6] == _sujiko[j];
            }
            for (uint256 j = 8; j < 14; j++) {
                isEqual = isEqual && sujikos[i].edges[0][j-8] == _sujiko[j];
            }
            for (uint256 j = 14; j < 20; j++) {
                isEqual = isEqual && sujikos[i].edges[1][j-14] == _sujiko[j];
            }
            if(isEqual) {
                return false;
            }
        }
        return true;
    }

    function contributeWithSujiko62(uint256[20] memory _sujiko) public returns (bool) {
        require(sujikosCounter.current() < limitSujikos, "Error: Reached limit of sujikos");
        sujiko62Struct memory newSujiko62 = sujiko62Struct([uint256(0), 0, 0, 0, 0, 0],[uint256(0), 0], [[uint256(0),0,0,0,0,0],[uint256(0),0,0,0,0,0]]);
        for (uint256 i = 0; i < 6; i++) {
            newSujiko62.squares[i] = _sujiko[i];
        }
        for (uint256 i = 6; i < 8; i++) {
            newSujiko62.circles[i - 6] = _sujiko[i];
        }
        for (uint256 i = 8; i < 14; i++) {
            newSujiko62.edges[0][i - 8] = _sujiko[i];
        }
        for (uint256 i = 14; i < 20; i++) {
            newSujiko62.edges[1][i - 14] = _sujiko[i];
        }
        sujikos[sujikosCounter.current()] = newSujiko62;
        sujikosCounter.increment();
        return true;
    }

    function mintNFT(address personAddress) public {

        uint256 newItemId = _tokenIds.current();
        string memory svg3 = string(abi.encodePacked(svg1, "Thanks for the contribution!", svg2));
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', "Sujiko Contribuitor",
                        '", "description": "This NFT certifies that you have contributed with your own Sujiko", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg3)),
                        '"}'
                    )
                )
            )
        );

        string memory tokenUri = string(abi.encodePacked("data:application/json;base64,", json));
        
        _safeMint(personAddress, newItemId);
        _setTokenURI(newItemId, tokenUri);

        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, personAddress);
    }
}
