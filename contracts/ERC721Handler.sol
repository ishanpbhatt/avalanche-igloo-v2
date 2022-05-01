//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./IglooNFT.sol";

contract ERC721Handler {
    IglooNFT IglooContract;
    address _bridgeAddress;

    constructor(address bridgeAddr) {
        IglooContract = new IglooNFT();
        _bridgeAddress = bridgeAddr;
    }

    // I'm pretty sure I have to unpack the data on my end, or it'll make it easier for you
    function executeProposal(address userAddress, string memory key) public {
        require(
            msg.sender == _bridgeAddress,
            "invalid permissions for executing this function"
        );
        IglooContract.mint(userAddress, key);
    }
}
