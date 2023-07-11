// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString, ExtLibString} from "../utils/ExtLibString.sol";

struct css {
    string elements;
}

/* CSS STRUCTURE OPERATIONS */
function readCSS(css memory _css) pure returns (string memory css_) {
    return _css.elements;
}

function addCSSElement(css memory _css, string memory _identifier, string memory _element) pure returns (css memory) {
    _css.elements = string.concat(_css.elements, _identifier, " { ", _element, " }");
    return _css;
}

using {readCSS, addCSSElement} for css global;
