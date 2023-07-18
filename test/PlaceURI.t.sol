// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/PlaceURI.sol";

contract UITest is Test {
    UIProvider public placeURI;
    uint256 goerliFork;

    constructor() {
        goerliFork = vm.createSelectFork(vm.envString("RPC_URL_GOERLI"));
        placeURI = new UIProvider();
    }

    function testSiteOutput() public {
        bytes memory input = hex"0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c";
        string memory result = placeURI.renderUI(input);
        PlaceEthersScripts placeEthersScripts = PlaceEthersScripts(placeURI.placeEthersScripts());
        IERC20 placeToken = IERC20(placeURI.PLACE_TOKEN());
        placeToken.approve(placeURI.PLACE_ADDRESS(), 1000);
        emit log_named_uint("allowance", placeEthersScripts.getTokenApprovalAmount(placeURI.PLACE_TOKEN(),placeURI.PLACE_ADDRESS()));
        vm.writeFile("test/output/renderedPlaceUI.html", result);
    }
}
