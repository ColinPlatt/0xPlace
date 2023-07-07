// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { WebSafeColors } from "./utils/WebSafeColors.sol";
import { html, fn, arrowFn } from "./types/vu3.sol";
import { libBrowserProvider, libJsonRPCProvider } from "./utils/libBrowserProvider.sol";
import { ExtLibString, LibString } from "./utils/ExtLibString.sol";
import { Base64 } from "lib/solady/src/utils/Base64.sol";

contract UIProvider {

    function _getPage(html memory _page) internal view returns (string memory) {
        
        _page.title('0xPlace');
        
    
        return _page.read();
    }



    function renderUI(bytes memory pixels) external view returns (string memory) {
        html memory page; // initialize a new html page

        return _getPage(page);
    }
}