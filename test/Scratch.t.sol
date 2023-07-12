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
        uint256 _len;
        uint256 _ptr;
    }

    struct childCallback_ {
        string prop;
        function () pure returns (string memory) callback;
    }

    function memcpy(uint256 dest, uint256 src, uint256 len) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint256 mask = type(uint256).max;
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
        uint256 ptr;
        uint256 len;
        assembly {
            ptr := add(self, 0x20)
            len := mload(self)
        }
        return slice(len, ptr);
    }

    function toStringCallback(slice memory self) internal pure returns (bytes memory) {
        bytes memory ret;
        uint256 retptr;
        assembly {
            retptr := add(ret, 0x20)
        }

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

    struct Callback {
        string prop;
        string child;
        bytes32 callbackFn;
        bytes[] childrenCallbacks;
    }

    function _encodeFn(function () pure returns (string memory) fn) internal pure returns (bytes32 ret) {
        assembly {
            ret := fn
        }
    }

    function _decodeFn(bytes32 fn) internal pure returns (function () pure returns (string memory) ret) {
        assembly {
            ret := fn
        }
    }

    function testEmptyFn() public {
        function () pure returns (string memory) fn;
        function () pure returns (string memory) fn2;
        function (string memory) pure returns (string memory) fn3;
        bytes32 _fn;
        bytes32 _fn2;
        bytes32 _fn3;

        assembly {
            _fn := fn
        }

        emit log_named_bytes32("_fn", _fn);

        assembly {
            _fn2 := fn2
        }

        emit log_named_bytes32("_fn2", _fn2);

        assembly {
            _fn3 := fn3
        }

        emit log_named_bytes32("_fn3", _fn3);


    }
    
    function basic1() internal pure returns (string memory) {
        return "return from basic1";
    }

    function basic2() internal pure returns (string memory) {
        return "return from basic2";
    }

    function testFunctionWrite() public {
        bytes[] memory childrenCallbacks = new bytes[](2);
        Callback memory callback = Callback("prop", "child", _encodeFn(basic1), childrenCallbacks);

        bytes memory testCallback = abi.encode(callback);

        emit log_named_bytes("testCallback", testCallback);

        Callback memory callbackRet = abi.decode(testCallback, (Callback));

        emit log_named_string("callbackRet.prop", callbackRet.prop);
        emit log_named_string("callbackRet.child", callbackRet.child);
        emit log_named_bytes32("callbackRet.callbackFn", callbackRet.callbackFn);
        emit log_named_string("callbackRet.callbackFn", _decodeFn(callbackRet.callbackFn)());


        Callback memory callback2 = Callback("prop", "child", _encodeFn(basic2), childrenCallbacks);

        bytes memory testCallback2 = abi.encode(callback2);

        emit log_named_bytes("testCallback2", testCallback2);

        Callback memory callbackRet2 = abi.decode(testCallback2, (Callback));

        emit log_named_string("callbackRet2.prop", callbackRet2.prop);
        emit log_named_string("callbackRet2.child", callbackRet2.child);
        emit log_named_bytes32("callbackRet2.callbackFn", callbackRet2.callbackFn);
        emit log_named_string("callbackRet2.callbackFn", _decodeFn(callbackRet2.callbackFn)());
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
