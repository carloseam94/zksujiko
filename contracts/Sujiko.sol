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

contract Sujiko is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds;
    Counters.Counter private sujikosCounter;

    struct sujikoStruct {
       uint256[9] squares;
       uint256[4] circles;
    }

    address public verifierAddr;
    uint256 public limitSujikos;
    sujikoStruct[32] sujikos;

    // Black svg with white text over it
    string svg1 = '<svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg"><rect width="100%" height="100%"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="fill:#fff;font-family:sans;font-size:20px">';
    string svg2 = "</text></svg>";

    constructor(address _verifierAddr) ERC721("Sujiko", "ZKSUJIKO") {
        verifierAddr = _verifierAddr;
        limitSujikos = 32;
        sujikos[sujikosCounter.current()] = sujikoStruct([uint256(0), 0, 0, 0, 0, 0, 8, 0, 7],[uint256(10), 21, 18, 20]);
        sujikosCounter.increment();
    }

    function random() public view returns (uint256) {
        return uint256(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % (sujikosCounter.current()));
    } 

    function getNewSujiko(uint256 _i) public view returns (uint256[9] memory, uint256[4] memory, uint256) {
        require(_i >= 0 && _i < sujikosCounter.current(), "Error: Invalid sujiko index");
        return (sujikos[_i].squares, sujikos[_i].circles, sujikosCounter.current());
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
        require(contributeWithSujiko(input));
        mintNFT();
        return true;
    }

    function isNewSujiko(uint256[13] memory _sujiko) public view returns (bool) {
        uint256 currentSujikosCounter = sujikosCounter.current();
        for (uint256 i = 0; i < currentSujikosCounter; i++) {
            bool isEqual = true;
            for (uint256 j = 0; j < 9; j++) {
                isEqual = isEqual && sujikos[i].squares[j] == _sujiko[j];
            }
            for (uint256 j = 0; j < 4; j++) {
                isEqual = isEqual && sujikos[i].circles[j] == _sujiko[9 + j];
            }
            if(isEqual) {
                return false;
            }
        }
        return true;
    }

    function contributeWithSujiko(uint256[13] memory _sujiko) public returns (bool) {
        require(sujikosCounter.current() < limitSujikos, "Error: Reached limit of sujikos");
        sujikoStruct memory newSujiko = sujikoStruct([uint256(0),0,0,0,0,0,0,0,0], [uint256(0),0,0,0]);
        for (uint256 i = 0; i < 9; i++) {
            newSujiko.squares[i] = _sujiko[i];
        }
        for (uint256 i = 9; i < 13; i++) {
            newSujiko.circles[i - 9] = _sujiko[i];
        }
        sujikos[sujikosCounter.current()] = newSujiko;
        sujikosCounter.increment();
        return true;
    }

    function mintNFT() private {

        uint256 newItemId = sujikosCounter.current();
        string memory svg3 = string(abi.encodePacked(svg1, "Thanks for the contribution! (Sujiko #", newItemId.toString(), ")", svg2));
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', "Sujiko Contribution",
                        '", "description": "This NFT certifies that you have contributed with your own Sujiko", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg3)),
                        '"}'
                    )
                )
            )
        );

        string memory tokenUri = string(abi.encodePacked("data:application/json;base64,", json));
        
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenUri);

    }
}
