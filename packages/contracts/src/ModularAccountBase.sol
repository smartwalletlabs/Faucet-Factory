// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {PackedUserOperation} from "@account-abstraction/interfaces/PackedUserOperation.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {IAccountExecute} from "@account-abstraction/interfaces/IAccountExecute.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

abstract contract ModularAccountBase is IAccount, Initializable {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint8 constant SIG_VALIDATION_PASSED = 0;
    uint8 constant SIG_VALIDATION_FAILED = 1;
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
        validationData = _validateUserOp(userOp, userOpHash);
        assembly ("memory-safe") {
            if missingAccountFunds {
                pop(call(gas(), caller(), missingAccountFunds, codesize(), 0x00, codesize(), 0x00))
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    //@dev we are using ECDSA recovery for this version, later versions would include validation modules
    function _validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 signedHash=MessageHashUtils.toEthSignedMessageHash(userOpHash);
        (address recovered,,)=ECDSA.tryRecover(signedHash, userOp.signature);
        if (recovered == address(0) || recovered != _getOwner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_PASSED;
    }

    function _getOwner() internal view virtual returns (address);

}
