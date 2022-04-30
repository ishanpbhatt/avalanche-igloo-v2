//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

contract Storage {
    event PutData(address userAddress, string key);

    mapping(address => mapping(string => bytes)) public dataStorage;

    function putData(
        address userAddress,
        string memory key,
        bytes memory value
    ) public {
        dataStorage[userAddress][key] = value;
        emit PutData(userAddress, key);
    }
}
