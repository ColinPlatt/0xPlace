// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { WebSafeColors } from "./utils/WebSafeColors.sol";
import { html, fn, arrowFn, css } from "./types/vu3.sol";
import { libBrowserProvider, libJsonRPCProvider } from "./utils/libBrowserProvider.sol";
import { ExtLibString, LibString } from "./utils/ExtLibString.sol";
import { Base64 } from "lib/solady/src/utils/Base64.sol";
import { HTML } from "./utils/HTML.sol";

contract UIProvider {
    using HTML for string;

    function _getCSS() internal pure returns (string memory) {
        css memory style;

        style.addCSSElement(
            'body', 
            string.concat(
                string('background-color').cssDecl('#0f1316'),
                string('color').cssDecl('#fff'),
                string('font-family').cssDecl("'Courier New', Courier, monospace"),
                string('padding').cssDecl('0.25rem 1rem')
            )
        );

        return style.readCSS();

    }

    function _getPage(html memory _page) internal view returns (string memory) {
        
        _page.title('0xPlace');
        _page.style(_getCSS());        
    
        return _page.read();
    }



    function renderUI(bytes memory pixels) external view returns (string memory) {
        html memory page; // initialize a new html page

        return _getPage(page);
    }
}