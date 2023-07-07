// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract WebSafeColors {
    function writeColors() public pure returns (bytes memory) {
        bytes memory _webSafeColors = new bytes(216*3);

        bytes1[6] memory colors = [bytes1(0x00), bytes1(0x33), bytes1(0x66), bytes1(0x99), bytes1(0xCC), bytes1(0xFF)];

        unchecked {
            uint256 i = 0;
            for (uint256 r = 0; r < 6; r++) {
                for (uint256 g = 0; g < 6; g++) {
                    for (uint256 b = 0; b < 6; b++) {
                        _webSafeColors[i] = colors[r];
                        _webSafeColors[i + 1] = colors[g];
                        _webSafeColors[i + 2] = colors[b];
                        i += 3;
                    }
                }
            }
        }

        return _webSafeColors;
    }
}
