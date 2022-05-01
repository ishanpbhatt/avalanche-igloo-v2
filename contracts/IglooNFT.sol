//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract IglooNFT is ERC721 {
    uint256 _currentId;
    address _owner;

    mapping(address => mapping(string => bool)) keyValueMapping;

    constructor() ERC721("IGLT", "IglooNFT") {
        _owner = msg.sender;
        _currentId = 0;
    }

    function isStorageMatch(address addr, string memory key)
        public
        view
        returns (bool)
    {
        return keyValueMapping[addr][key];
    }

    function mint(address addr, string memory key) public {
        require(msg.sender == _owner, "not allowed to mint this NFT");
        _safeMint(addr, _currentId);
        keyValueMapping[addr][key] = true;
        _currentId += 1;
    }
}
