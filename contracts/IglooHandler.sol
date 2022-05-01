//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "./IglooNFT.sol";

contract IglooHandler {
    IglooNFT IglooContract;
    address bridgeAddress;

    constructor(address bridgeAddr, address iglooContractAddr) {
        IglooContract = IglooNFT(iglooContractAddr);
        bridgeAddress = bridgeAddr;
    }

    // I'm pretty sure I have to unpack the data on my end, or it'll make it easier for you
    function executeProposal(address userAddress, string memory key) public {
        IglooContract.mint(userAddress, key);
    }
}
