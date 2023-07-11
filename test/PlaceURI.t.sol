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
        bytes memory input;
        string memory result = placeURI.renderUI(input);
        emit log_named_string("website", result);
        vm.writeFile("test/output/renderedPlaceUI.html", result);
    }
}
