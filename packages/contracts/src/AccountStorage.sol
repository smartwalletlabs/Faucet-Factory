// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//implementation of ERC-7201 Namespace to prevent storage collisions

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    struct ValidationStorage {
        address module;
    }

    struct ExecutionStorage {
        address module;
    }

    struct AccountStorageStruct {
        mapping(bytes21 validationLookupKey => ValidationStorage) validationStorage;
        mapping(bytes4 selector => ExecutionStorage) executionStorage;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    bytes32 constant _ACCOUNT_STORAGE =
        keccak256(abi.encode(uint256(keccak256("accountStorage")) - 1)) & ~bytes32(uint256(0xff));

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getAccountStorage() pure returns (AccountStorageStruct storage s) {
        bytes32 accountStorage = _ACCOUNT_STORAGE;
        assembly {
            s.slot := accountStorage
        }
    }

