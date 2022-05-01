//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Storage {
    bytes ZERO_BYTE = "0x";

    event PutData(address userAddress, string key);

    mapping(address => mapping(string => string)) public dataStorage;

    function putData(
        address userAddress,
        string memory key,
        string memory value
    ) public {
        require(
            bytes(dataStorage[userAddress][key]).length == 0,
            "can't override data"
        );
        dataStorage[userAddress][key] = value;
        emit PutData(userAddress, key);
    }
}
