// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/StdJson.sol";

contract ScratchTest is Test {
    using stdJson for string;

    bytes public webSafeColors;

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

    function testRunColors() public {
        emit log_bytes(writeColors());
    }

    function testColors() public {
        webSafeColors = writeColors();

        bytes[] memory colorsArr = new bytes[](216);

        unchecked {
            for (uint256 i = 0; i < 216; i++) {
                colorsArr[i] = bytes.concat(webSafeColors[i * 3], webSafeColors[i * 3 + 1], webSafeColors[i * 3 + 2]);
            }
        }

        string memory output = vm.serializeBytes("color", "websafeColors", colorsArr);

        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/output/colors.json");

        output.write(path);

        emit log_bytes(webSafeColors);
    }
}
