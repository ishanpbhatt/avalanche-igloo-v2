//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./IglooNFT.sol";

contract ERC721Handler {
    IglooNFT IglooContract;

    constructor(address contractAddress) {
        IglooContract = IglooNFT(contractAddress);
    }

    function executeProposal(address userAddress, string memory key) public {
        IglooContract.mint(userAddress, key);
    }
}
