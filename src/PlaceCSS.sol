// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {WebSafeColors} from "./utils/WebSafeColors.sol";
import "./types/vu3.sol";
import {libBrowserProvider, libJsonRPCProvider} from "./utils/libBrowserProvider.sol";
import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import {HTML} from "./utils/HTML.sol";

contract PlaceCSS {
    using HTML for string;

    function _getTitleCSS(css memory _style) private pure {
        _style.addCSSElement(
            ".title",
            string.concat(
                string("font-size").cssDecl("1.5em"),
                string("font-weight").cssDecl("600"),
                string("font-family").cssDecl("inherit"),
                string("color").cssDecl("#fff"),
                string("margin").cssDecl("0")
            )
        );
    }

    function _getHeaderBarCSS(css memory _style) private pure {
        _style.addCSSElement(
            "#header-bar",
            string.concat(
                string("display").cssDecl("flex"),
                string("justify-content").cssDecl("space-between"),
                string("align-items").cssDecl("center"),
                string("padding").cssDecl("5px"),
                string("height").cssDecl("35px"),
                string("position").cssDecl("fixed"),
                string("top").cssDecl("0"),
                string("width").cssDecl("100%"),
                string("z-index").cssDecl("999")
            )
        );
    }

    function _getTopRight(css memory _style) private pure {
        _style.addCSSElement(
            ".top-right",
            string.concat(
                string("display").cssDecl("flex"),
                string("align-items").cssDecl("center"),
                string("right").cssDecl("15px"),
                string("padding-right").cssDecl("25px")
            )
        );
    }

    function _getDotCSS(css memory _style) private pure {
        _style.addCSSElement(
            ".dot",
            string.concat(
                string("height").cssDecl("10px"),
                string("width").cssDecl("10px"),
                string("background-color").cssDecl("red"),
                string("border-radius").cssDecl("50%"),
                string("margin-top").cssDecl("10px"),
                string("margin-right").cssDecl("5px")
            )
        );
    }

    function _getFullHeaderBar(css memory _style) private pure {
        _getTitleCSS(_style);
        _getHeaderBarCSS(_style);
        _getTopRight(_style);
        _getDotCSS(_style);
    }

    function _getButtonCSS(css memory _style) private pure {
        _style.addCSSElement(
            "button",
            string.concat(
                string("height").cssDecl("2.25rem"),
                string("cursor").cssDecl("pointer"),
                string("background").cssDecl("#027cfd"),
                string("font-family").cssDecl("inherit"),
                string("padding").cssDecl("0.25rem 1rem"),
                string("color").cssDecl("white"),
                string("margin").cssDecl("1rem 1rem 0"),
                string("font-size").cssDecl("1rem"),
                string("border-radius").cssDecl("7px")
            )
        );
    }

    function _getMainCSS(css memory _style) private pure {
        _style.addCSSElement(
            "#info",
            string.concat(
                string("margin-top").cssDecl("60px")
            )
        );
        
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

        _getButtonCSS(_style);

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
    }

    function _getCanvasCSS(css memory _style) private pure {
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
    }

    function _getCSS() public pure returns (string memory) {
        css memory style;

        _getFullHeaderBar(style);

        _getMainCSS(style);

        _getCanvasCSS(style);

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