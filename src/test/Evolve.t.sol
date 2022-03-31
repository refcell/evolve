// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {Evolve} from "../Evolve.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";

contract EvolveTest is DSTestPlus {
    Evolve evolve;

    function setUp() public {
        console.log(unicode"🧪 Testing Evolve...");
        evolve = new Evolve();
    }

    function invariantImmutables() public {
        assertEq(evolve.MAXIMUM_SUPPLY(), 1_000_000_000);
        assertEq(evolve.warden(), address(this));
    }

    function invariantMetadata() public {
        assertEq(evolve.name(), "Evolve");
        assertEq(evolve.symbol(), "VOLV");
        assertEq(evolve.decimals(), 18);
    }

    function testMint(address user) public {
        if (user == address(this) || user == address(0x0)) {
            user = address(420);
        }

        // A random person can't mint
        startHoax(user, user, type(uint256).max);
        vm.expectRevert(abi.encodeWithSignature("MintCapacityReached()"));
        evolve.mint(address(0xBEEF), 1);
        vm.stopPrank();

        // The warden can't mint without approving itself
        vm.expectRevert(abi.encodeWithSignature("MintCapacityReached()"));
        evolve.mint(address(0xBEEF), 1);

        // Warden can mint
        evolve.setMintable(address(this), 100);
        assertEq(evolve.mintable(address(this)), 100);
        assertEq(evolve.minted(address(this)), 0);
        evolve.mint(address(0xBEEF), 100);
        assertEq(evolve.totalSupply(), 100);
        assertEq(evolve.balanceOf(address(0xBEEF)), 100);
        assertEq(evolve.mintable(address(this)), 100);
        assertEq(evolve.minted(address(this)), 100);

        // An approved minter can mint
        evolve.setMintable(user, 100);
        assertEq(evolve.mintable(user), 100);
        assertEq(evolve.minted(user), 0);
        startHoax(user, user, type(uint256).max);
        evolve.mint(address(1337), 100);
        vm.stopPrank();
        assertEq(evolve.totalSupply(), 200);
        assertEq(evolve.balanceOf(address(1337)), 100);
        assertEq(evolve.mintable(user), 100);
        assertEq(evolve.minted(user), 100);

        // The user can't mint beyond its allowed amount
        startHoax(user, user, type(uint256).max);
        vm.expectRevert(abi.encodeWithSignature("MintCapacityReached()"));
        evolve.mint(address(0xBEEF), 1);
        vm.stopPrank();

        // SUCCESS
        console.log(unicode"✅ minting tests passed!");
    }
}
