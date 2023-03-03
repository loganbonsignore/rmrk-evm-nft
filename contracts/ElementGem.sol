// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "./BaseGem.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/extension/soulbound/RMRKSoulbound.sol";

// Creating soulbound token
contract ElementGem is RMRKSoulbound, BaseGem {
    string private constant _POST_URL_PER_TYPE_FIRE = "fire";
    string private constant _POST_URL_PER_TYPE_EARTH = "earth";
    string private constant _POST_URL_PER_TYPE_WATER = "water";
    string private constant _POST_URL_PER_TYPE_AIR = "air";

    constructor(
        string memory collectionMetadata_,
        string memory tokenURI_,
        address snakeSoldiers_,
        uint256 maxSupply_
    )
        BaseGem(
            "Bon Flyers Element Gem",
            "BFEG",
            collectionMetadata_,
            tokenURI_,
            snakeSoldiers_,
            maxSupply_
        )
    {}

    // We need to override this function because this lets people know we support Soulbound and other tokens
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(RMRKSoulbound, IERC165, RMRKEquippable)
        returns (bool)
    {
        return
            RMRKSoulbound.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(RMRKCore, RMRKSoulbound) {
        // super will always call the rightmost contract on the above override
        // We want to call _beforeTokenTransfer on RMRKSoulbound because
        // it reverts if trying to transfer soulbound token
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Elements are assigned round robing style, it's an easy way to make sure
    // that the number of snakes per element is as similar as possible.
    function _postUriFor(
        uint256 tokenId
    ) internal pure override returns (string memory) {
        uint256 mod = tokenId % 4;
        if (mod == 0) return _POST_URL_PER_TYPE_FIRE;
        else if (mod == 1) return _POST_URL_PER_TYPE_EARTH;
        else if (mod == 2) return _POST_URL_PER_TYPE_WATER;
        else return _POST_URL_PER_TYPE_AIR;
    }
}
