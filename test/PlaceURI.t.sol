// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/PlaceURI.sol";

contract UITest is Test {
    UIProvider public placeURI;

    constructor() {
        placeURI = new UIProvider();
    }

    function testSiteOutput() public {
        bytes memory input = hex'0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c';
        string memory result = placeURI.renderUI(input);
        emit log_named_string("website", result);
        vm.writeFile("test/output/renderedPlaceUI.html", result);
    }
}
