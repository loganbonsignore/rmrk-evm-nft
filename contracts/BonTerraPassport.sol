// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// If you want to unnest your gem or get a new one, you'll need this passport
// This implementation of is soulbound will check the owners balance of the erc20 token and will burn it to allow it to transfer
contract BonTerraPassport is ERC20, ERC20Burnable, Ownable {
    address private _factionGem;

    constructor(address factionGem) ERC20("BonTerra Passport", "BTP") {
        setFactionGem(factionGem);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burnFromFactionGem(address owner, uint256 amount) public {
        // Only callable from factionGem address
        if (_msgSender() != _factionGem) revert("Not Faction Gem");

        _burn(owner, amount);
    }

    function setFactionGem(address factionGem) public onlyOwner {
        _factionGem = factionGem;
    }
}
