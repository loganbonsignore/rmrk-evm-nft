# Bon Flyer NFT

[Tutorial Video](https://twitter.com/stoicdev0/status/1630240260331323392?utm_source=ethdenver&utm_medium=presentation&utm_campaign=ethdenver)  
[Tutorial Repo](https://github.com/steven2308/snake-soldiers-tutorials)

The contracts created in the repo are deployed to Goerli testnet:
- Bon Flyer: `0x1f085538f65eaaB060FDb803900D91343006eE3f`
- BonTerra Passport: `0x30667905b1AefBa859644fc07DC1738040C4452e`
- Element Gem: `0x208ed97E61d287047C1fD5c2D220B4eb19B03edC`
- Faction Gem: `0xd8aF3aCC0C7aC346FA2802E398819c8dBb4a6cf6`
- Skill Gem: `0xC4756CFE7C84149df23984EB29c1a2F113001dD8`
- Flyer Catalog: `0x4A69C360B4a27c841ce469D8823404A3475e26C6`


### Helpful Commands
1. Install packages with `yarn` or `npm i`
2. Test contracts compile: `yarn hardhat compile`
3. Check contract size: `yarn hardhat size-contracts`
4. Run tests: `yarn run test`
5. Check test coverage: `yarn hardhat coverage`
6. Run prettier: `yarn run prettier`
7. Update types: `yarn hardhat typechain`
8. Copy .env.example into .env and set your variables
9. Use `contracts/`, `tests/` and `scripts/` to build your code.
10. Deploy on testnet: `yarn hardhat run scripts/deploy.ts --network goerli`
11. Verify contracts, using the contract address and arguments from previous step:
   ```
      yarn hardhat verify 0x.... --network goerli --contract contracts/SimpleEquippable.sol:SimpleEquippable --arguments ...
   ```

### To Do
1. Test suite