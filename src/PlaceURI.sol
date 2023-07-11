// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {WebSafeColors} from "./utils/WebSafeColors.sol";
import {html, childCallback, childCallback_, fn, arrowFn, css} from "./types/vu3.sol";
import {libBrowserProvider, libJsonRPCProvider} from "./utils/libBrowserProvider.sol";
import {ExtLibString, LibString} from "./utils/ExtLibString.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import {HTML} from "./utils/HTML.sol";

contract UIProvider {
    using HTML for string;

    function _getInfoDiv(html memory _page) internal pure {
        childCallback_[] memory infoChildren = new childCallback_[](2);

        infoChildren[0] = childCallback_('0xPlace', HTML.h2_);
        infoChildren[1] = childCallback_('0xPlace is an entirely onchain canvas that let\'s users claim and update pixels. When a pixel is first claimed (0.0001 ETH each), the user receives 100 $PLACE tokens. Each change requires 1 $PLACE token which is paid to the current owner of the pixel.', HTML.p_);

        _page.divChildren_(
            string('id').prop('info'),
            infoChildren
        );

    }


    function _getBody(html memory _page) internal pure{
        
        _getInfoDiv(_page);

    }

    function _getPage(html memory _page) internal pure returns (string memory) {
        _page.title("0xPlace");
        _page.style(PlaceCSS._getCSS());
        _getBody(_page);


        return _page.read();
    }

    function renderUI(bytes memory pixels) external pure returns (string memory) {
        html memory page; // initialize a new html page

        return _getPage(page);
    }
}

// we place the elements in a separate library to make things more legible

library PlaceCSS {
    using HTML for string;

    function _getButtonCSS(css memory _style) private pure returns (css memory) {
        _style.addCSSElement(
            "button",
            string.concat(
                string("height").cssDecl("2.25rem"),
                string("cursor").cssDecl("pointer"),
                string("background").cssDecl("#027cfd"),
                string("font-family").cssDecl("inherit"),
                string("padding").cssDecl("0.25rem 1rem"),
                string("color").cssDecl("white"),
                string("font-weight").cssDecl("800"),
                string("margin").cssDecl("1rem 1rem 0"),
                string("font-size").cssDecl("1rem")
            )
        );

        return _style;
    }

    function _getMainCSS(css memory _style) private pure returns (css memory) {
        _style.addCSSElement(
            "body",
            string.concat(
                string("background-color").cssDecl("#0f1316"),
                string("color").cssDecl("#fff"),
                string("font-family").cssDecl("'Courier New', Courier, monospace"),
                string("padding").cssDecl("0.25rem 1rem")
            )
        );

        _style.addCSSElement(
            "input",
            string.concat(
                string("background").cssDecl("transparent"),
                string("width").cssDecl("5rem"),
                string("margin").cssDecl("1rem 1rem 0")
            )
        );

        _style = _getButtonCSS(_style);

        _style.addCSSElement(
            'input[type="color"]',
            string.concat(
                string("height").cssDecl("2rem"),
                string("padding").cssDecl("0"),
                string("background").cssDecl("transparent !important"),
                string("border-radius").cssDecl("10px"),
                string("position").cssDecl("relative"),
                string("border").cssDecl("none"),
                string("cursor").cssDecl("pointer")
            )
        );

        return _style;
    }

    function _getCanvasCSS(css memory _style) private pure returns (css memory) {
        _style.addCSSElement(
            "#pixel-art-area",
            string.concat(
                string("display").cssDecl("flex"),
                string("flex-direction").cssDecl("row"),
                string("flex-wrap").cssDecl("wrap"),
                string("overflow").cssDecl("hidden"),
                string("border-radius").cssDecl("4px"),
                string("padding").cssDecl("0.05px")
            )
        );

        _style.addCSSElement("#pixel-art-area input", string.concat(string("background").cssDecl("#101316")));

        _style.addCSSElement(
            "#canvas-area",
            string.concat(string("position").cssDecl("relative"), string("border").cssDecl("5px solid #b9b9b9"))
        );

        _style.addCSSElement(
            ".cursor-highlight",
            string.concat(
                string("position").cssDecl("absolute"),
                string("background-color").cssDecl("rgba(255, 255, 255, 0.3)"),
                string("border").cssDecl("1px solid white"),
                string("pointer-events").cssDecl("none")
            )
        );

        return _style;
    }

    function _getCSS() internal pure returns (string memory) {
        css memory style;

        style = _getMainCSS(style);

        style = _getCanvasCSS(style);

        style.addCSSElement(
            "#button-container",
            string.concat(
                string("display").cssDecl("flex"),
                string("justify-content").cssDecl("space-between"),
                string("align-items").cssDecl("center"),
                string("max-width").cssDecl("400px"),
                string("margin-bottom").cssDecl("1rem")
            )
        );

        style.addCSSElement(
            "#pixel-art-options",
            string.concat(string("display").cssDecl("flex"), string("align-items").cssDecl("center"))
        );

        style.addCSSElement(
            "#color-selector-container",
            string.concat(
                string("display").cssDecl("flex"),
                string("width").cssDecl("20rem"),
                string("position").cssDecl("relative"),
                string("align-items").cssDecl("center")
            )
        );

        return style.readCSS();
    }
}
