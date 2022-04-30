//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "/Users/ishan/.brownie/packages/OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/token/ERC721/ERC721.sol";

contract IglooNFT is ERC721 {
    uint256 currentId;

    mapping(address => mapping(string => bool)) keyValueMapping;

    constructor() ERC721("IGLT", "IglooNFT") {
        currentId = 0;
    }

    function isStorageMatch(address addr, string memory key)
        public
        view
        returns (bool)
    {
        return keyValueMapping[addr][key];
    }

    function mint(address addr, string memory key) public {
        _mint(addr, currentId);
        keyValueMapping[addr][key] = true;
        currentId += 1;
    }
}
