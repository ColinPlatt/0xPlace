// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solady/src/tokens/ERC20.sol";

contract PlaceToken is ERC20 {
    constructor() {
        _mint(msg.sender, 26_214_400 * 10 ** decimals()); //100 tokens per pixel
    }

    function name() public pure override returns (string memory) {
        return "PlaceToken";
    }

    function symbol() public pure override returns (string memory) {
        return "PLACE";
    }
}
