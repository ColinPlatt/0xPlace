// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/StdJson.sol";
import "src/0xPlace.sol";

contract ZeroPlaceTest is Test {
    using stdJson for string;

    zeroxPlace public place;
    address public dep = address(0xad1);
    address public alice = address(0xa11ce);

    constructor() {
        vm.startPrank(dep);
        place = new zeroxPlace();
        vm.stopPrank();
    }

    function testSetup() public {
        assert(place.supportsInterface(0x57de26a4));

        PlaceToken token = PlaceToken(place.token());

        assertEq(token.balanceOf(address(place)), token.totalSupply(), "place balance before");

        vm.deal(alice, 100 ether);
        vm.startPrank(alice);

        for (uint256 i = 0; i < 2_621; i++) {
            place.claimPixel{value: 0.01 ether}(100);
        }

        for (uint256 i = 0; i < 44; i++) {
            place.claimPixel{value: 0.0001 ether}();
        }

        vm.stopPrank();

        assertEq(token.balanceOf(address(place)), 0, "place balance after");
        assertEq(token.balanceOf(alice), token.totalSupply(), "alice balance after");
        assertEq(place.canvas().length, place.MAX_PIXELS(), "canvas length");

        assertEq(place.ownerOf(0), dep, "owner of 0");
        assertEq(place.balanceOf(dep), 1, "balance of owner");
    }
}
