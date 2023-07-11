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

    function basicFunction() internal pure returns (string memory) {
        return "basicFunctionReturn";
    }

    struct slice {
        uint _len;
        uint _ptr;
    }

    struct childCallback_ {
        string prop;
        function () pure returns (string memory) callback;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = type(uint).max;
        if (len > 0) {
            mask = 256 ** (32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toSliceCallback(childCallback_ memory self) internal pure returns (slice memory) {
        uint ptr;
        uint len;
        assembly {
            ptr := add(self, 0x20)
            len := mload(self)
        }
        return slice(len, ptr);
    }

    function toStringCallback(slice memory self) internal pure returns (bytes memory) {
        bytes memory ret;
        uint retptr;
        assembly { retptr := add(ret, 0x20) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    function testFunctionRead() public {

        childCallback_ memory childCallback = childCallback_("prop", basicFunction);

        slice memory testSlice = toSliceCallback(childCallback);

        emit log_named_uint("testSlice._len", testSlice._len);
        emit log_named_uint("testSlice._ptr", testSlice._ptr);

        bytes memory testCallback = toStringCallback(testSlice);

        emit log_named_bytes("testCallback", testCallback);

        //emit log_named_string("testCallback.prop", testCallback.prop);
        //emit log_named_string("testCallback.callback", testCallback.callback());


    }

    /*

    function _getRecursive(html memory _page) internal pure {
        nesting memory _nest;

        _nest.addToNest(HTML.elOpen('div', HTML.prop('id', 'recursive-container')),true);
            _nest.addToNest(HTML.elOpen('div', HTML.prop('id', 'recursive-outer-container')),true);
                _nest.addToNest(HTML.div(HTML.prop('id', 'recursive-inner1-container'),''),false);
                _nest.addToNest(HTML.div(HTML.prop('id', 'recursive-inner2-container'),''),false);
            _nest.closeNestLevel('div');
        _nest.closeNestLevel('div');


        _page.appendBody(_nest.readNesting());
    }

    */
}
