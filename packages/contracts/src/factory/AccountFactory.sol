// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";
import {ModularAccount} from "../ModularAccount.sol";
import {LibClone} from "solady/utils/LibClone.sol";

/**
 * @title Account Factory
 * @author smartwalletlabs
 * @notice Factory to deploy modular accounts
 */
contract AccountFactory {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IEntryPoint immutable ENTRY_POINT;
    ModularAccount immutable ACCOUNT_IMPL;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AccountDeployed(address indexed account, address indexed owner, uint256 salt);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error InvalidAction();
    error TransferFailed();
    error NoCodeAccountImpl();

    /*CONSTRUCTOR*/
    constructor(IEntryPoint _entryPoint, ModularAccount _accountImpl) {
        ENTRY_POINT = _entryPoint;
        ACCOUNT_IMPL = _accountImpl;
        if (address(_accountImpl).code.length == 0) {
            revert NoCodeAccountImpl();
        }
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createAccount(address owner, uint256 salt) external returns (ModularAccount account) {
        bytes32 combinedSalt = getSalt(owner, salt);
        (bool isAlreadyDeployed, address instance) = LibClone.createDeterministicERC1967(address(ACCOUNT_IMPL), combinedSalt);
        if (!isAlreadyDeployed) {
            ModularAccount(instance).initialize(owner);
            emit AccountDeployed(instance,owner,salt);
        }
        return ModularAccount(instance);
    }

    function getSalt(address owner, uint256 salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, salt));
    }

    function getAddress(address owner, uint256 salt) view external returns (address account) {
        bytes32 combinedSalt = getSalt(owner, salt);
        account=LibClone.predictDeterministicAddressERC1967(address(ACCOUNT_IMPL), combinedSalt, address(this));
    }
}
