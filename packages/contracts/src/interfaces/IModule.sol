// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;
import  {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IModule is IERC165 {
    /**
     * @notice initialize module data for modular account
     * @param data optional data to be decoded to set state for the modular account
     */
    function onInstall(bytes calldata data) external;

        /**
     * @notice clear module data for modular account
     * @param data optional data to be decoded  and used to clear state for the modular account
     */
    function onUninstall(bytes calldata data) external;

            /**
     * @notice returns a unique identifier for the module
     * 
     */
    function moduleId() external returns (string memory);
}