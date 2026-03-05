// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {IAccountExecute} from "@account-abstraction/interfaces/IAccountExecute.sol";

contract ModularAccountBase is IAccount, Initializable{
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData){
        validationData=_validateUserOp(userOp,userOpHash);
        assembly("memory-safe") {
            if missingAccountFunds {
                pop(call(gas(),caller(),missingAccountFunds,codesize(),0x00,codesize(),0x00))
            }
        }
    }

        /*//////////////////////////////////////////////////////////////
                              INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash) internal  returns (uint256 validationData) {
        
    }

}