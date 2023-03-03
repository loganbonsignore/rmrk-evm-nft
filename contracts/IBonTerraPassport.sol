// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

// If we import BonTerraPassport directly into the faction gem, it will include all of the bytecode
// So we create an interface with only the exclusive functions our faction gem will need
// This is an optimization that makes the total bytecode of our faction gem smaller, saving gas
// We only need balanceOf and burnFromFactionGem
interface IBonTerraPassport {
    function balanceOf(address account) external view returns (uint256);

    function burnFromFactionGem(address owner, uint256 amount) external;
}
