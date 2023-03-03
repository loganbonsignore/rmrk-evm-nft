// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.16;

import "@rmrk-team/evm-contracts/contracts/RMRK/access/Ownable.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/equippable/RMRKEquippable.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/extension/RMRKRoyalties.sol";
import "@rmrk-team/evm-contracts/contracts/RMRK/utils/RMRKCollectionMetadata.sol";

error GemAlreadyClaimed();
error CannotMintGemForNotOwnedToken();

// Making this abstract means it doesnt have to be a full implementation
// This contract is meant to be inherited
abstract contract BaseGem is
    Ownable,
    RMRKCollectionMetadata,
    RMRKRoyalties,
    RMRKEquippable
{
    // Address of snake soldiers contract
    address private immutable _snakeSoldiers;
    // Mapping to token id to if it was claimed or not
    mapping(uint256 => uint256) private _claimed;
    // Same for all tokens, fallback for legacy marketplaces
    string private _tokenURI;
    uint256 private _totalSupply;
    uint256 private _totalAssets;
    uint256 private immutable _maxSupply;

    // Used later to add initial asset on mint
    uint64 private constant _MAIN_ASSET_ID = uint64(1);
    // Using offsets like before
    uint256 internal constant _SOLDIERS_OFFSET = 200;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory collectionMetadata_,
        string memory tokenURI_,
        address snakeSoldiers_,
        uint256 maxSupply_
    )
        // Initializing imported contracts
        RMRKCollectionMetadata(collectionMetadata_)
        // Setting royalty reciever as deployer
        RMRKRoyalties(_msgSender(), 500) // 500 -> 5%
        // Assigning name and symbol
        RMRKEquippable(name_, symbol_)
    {
        _snakeSoldiers = snakeSoldiers_;
        _maxSupply = maxSupply_;
        _tokenURI = tokenURI_;
    }

    // These functions are for backwards compatibility
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function tokenURI(uint256) public view returns (string memory) {
        return _tokenURI;
    }

    // This function is added so we can easily check the address of snake soldiers
    function snakeSoldiers() external view returns (address) {
        return _snakeSoldiers;
    }

    function addAssetEntry(
        string memory metadataURI
    ) public virtual onlyOwnerOrContributor returns (uint256) {
        unchecked {
            _totalAssets += 1;
        }
        _addAssetEntry(uint64(_totalAssets), metadataURI);
        return _totalAssets;
    }

    function addEquippableAssetEntry(
        uint64 equippableGroupId,
        address catalogAddress,
        string memory metadataURI,
        uint64[] calldata partIds
    ) public virtual onlyOwnerOrContributor returns (uint256) {
        unchecked {
            _totalAssets += 1;
        }
        _addAssetEntry(
            uint64(_totalAssets),
            equippableGroupId,
            catalogAddress,
            metadataURI,
            partIds
        );
        return _totalAssets;
    }

    function addAssetToTokens(
        uint256[] calldata tokenIds,
        uint64 assetId,
        uint64 overwrites
    ) external onlyOwnerOrContributor {
        uint256 length = tokenIds.length;
        for (uint256 i; i < length; ) {
            _addAssetToToken(tokenIds[i], assetId, overwrites);
            unchecked {
                ++i;
            }
        }
    }

    function setValidParentForEquippableGroup(
        uint64 equippableGroupId,
        address parentAddress,
        uint64 slotPartId
    ) external onlyOwner {
        _setValidParentForEquippableGroup(
            equippableGroupId,
            parentAddress,
            slotPartId
        );
    }

    // Function to update royalty recipient
    function updateRoyaltyRecipient(
        address newRoyaltyRecipient
    ) external override onlyOwner {
        _setRoyaltyRecipient(newRoyaltyRecipient);
    }

    // Although this contract is not meant to recieve assets,
    // adding this to have in case someone sends native token to this contract
    function withdrawRaised(address to, uint256 amount) external onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    function claimed(uint256 snakeTokenId) external view returns (bool) {
        return _claimed[snakeTokenId] == 1;
    }

    function claimMany(uint256[] calldata snakeTokenIds) external {
        uint256 length = snakeTokenIds.length;
        for (uint256 i; i < length; ) {
            _claim(snakeTokenIds[0]);
            unchecked {
                ++i;
            }
        }
    }

    function claim(uint256 snakeTokenId) external {
        _claim(snakeTokenId);
    }

    function _claim(uint256 snakeTokenId) private {
        // We use the same id for the gem just because relationship is 1 to 1
        if (_claimed[snakeTokenId] == 1) revert GemAlreadyClaimed();

        // Mark as claimed
        _claimed[snakeTokenId] = 1;
        // Increase total supply
        _totalSupply += 1;

        // Make sure that whoever is claiming this token id is actually the owner of the token id
        // Get owner using Nestable interface
        address owner = IRMRKNestable(_snakeSoldiers).ownerOf(snakeTokenId);
        if (_msgSender() != owner) revert CannotMintGemForNotOwnedToken();

        // Finally, mint token, add to token, and accept
        _nestMint(_snakeSoldiers, snakeTokenId, snakeTokenId, "");
        _addAssetToToken(snakeTokenId, _MAIN_ASSET_ID, uint64(0));
        _acceptAsset(snakeTokenId, 0, _MAIN_ASSET_ID);
    }

    // Defined customized get asset metadata
    function getAssetMetadata(
        uint256 tokenId,
        uint64 assetId
    )
        public
        view
        override(AbstractMultiAsset, IRMRKMultiAsset)
        returns (string memory)
    {
        // Get base metadata uri
        string memory baseMetaUri = super.getAssetMetadata(tokenId, assetId);
        // Get token id
        string memory postUri = _postUriFor(tokenId);
        // Combine and return
        return string.concat(baseMetaUri, postUri);
    }

    // This function is used above, but not actually implemented yet
    // Using an abstract contract forces the inheriting contract to define
    function _postUriFor(
        uint256 tokenId
    ) internal pure virtual returns (string memory) {}
}
