// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.9;

contract Storage {
    bytes ZERO_BYTE = "0x";

    event PutData(address userAddress, string key);

    mapping(address => mapping(string => bytes)) public dataStorage;

    function putData(
        address userAddress,
        string memory key,
        bytes memory value
    ) public {
        require(
            dataStorage[userAddress][key].length == ZERO_BYTE.length,
            "can't override data"
        );
        dataStorage[userAddress][key] = value;
        emit PutData(userAddress, key);
    }
}
