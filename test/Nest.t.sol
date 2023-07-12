// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/utils/HTML.sol";
import "src/types/html.sol";
import "src/utils/FunctionCoder.sol";

contract NestTest is Test {
    /*
        '<div class="outermostProp">
            outermostChild
            '<div class='class="level1>'
                1a
                '<div class='class="level2>'
                    2a
                '</div>
            '</div>
            '<div class='class="level1>'
                1b
                '<div class='class="level2>'
                    2b
                    '<div class='class="level3>'
                        3b1
                    '</div>
                    '<div class='class="level3>'
                        3b2
                    '</div>
                '</div>
            '</div>
        '</div>
    
    */

    function _callBackbuilder(string memory _props, string memory _children, bytes32 fn, uint _childCount) internal pure returns (Callback memory) {
        string[] memory _inputs = new string[](2);
        _inputs[0] = _props;
        _inputs[1] = _children;

        return Callback(_inputs, fn, new bytes[](_childCount), '');
    }

    function _callBackbuilder(string memory _children, bytes32 fn, uint _childCount) internal pure returns (Callback memory) {
        string[] memory _inputs = new string[](1);
        _inputs[0] = _children;

        return Callback(_inputs, fn, new bytes[](_childCount), '');
    }

    function testNesting() public {
        Callback memory callbackOutermost = _callBackbuilder('class="outermostProp"', "outermostClient", FunctionCoder.encode(HTML.div), 2);
        Callback memory callbackLevel1a = _callBackbuilder('class="level1"', "1a", FunctionCoder.encode(HTML.div), 1);
        Callback memory callbackLevel2a = _callBackbuilder('class="level2"', "2a", FunctionCoder.encode(HTML.div), 0);
        Callback memory callbackLevel1b = _callBackbuilder('class="level1"', "1b", FunctionCoder.encode(HTML.div), 1);
        Callback memory callbackLevel2b = _callBackbuilder('class="level2"', "2b", FunctionCoder.encode(HTML.div), 2);
        Callback memory callbackLevel3b1 = _callBackbuilder('class="level3"', "3b1", FunctionCoder.encode(HTML.div), 0);
        Callback memory callbackLevel3b2 = _callBackbuilder('class="level3"', "3b2", FunctionCoder.encode(HTML.div), 0);

        callbackLevel1a.addToNest(0, callbackLevel2a);
        callbackOutermost.addToNest(0, callbackLevel1a);
        callbackLevel2b.addToNest(1, callbackLevel3b2);
        callbackLevel2b.addToNest(0, callbackLevel3b1);
        callbackLevel1b.addToNest(0, callbackLevel2b);
        callbackOutermost.addToNest(1, callbackLevel1b);

        string memory result = callbackOutermost.readNest();

        string memory expected = string.concat(
            '<div class="outermostProp">outermostClient',
                '<div class="level1">1a',
                    '<div class="level2">2a</div>',
                '</div>',
                '<div class="level1">1b',
                    '<div class="level2">2b',
                        '<div class="level3">3b1</div>',
                        '<div class="level3">3b2</div>',
                    '</div>',
                '</div>',
            '</div>'
        );
        emit log_string(result);
        assertEq(result, expected, "Nesting failed");
    }

    function clunkyCustomHTMLThing(string memory _props, string memory _children) internal pure returns (string memory) {
        return string.concat(
            '<custom ', _props, '>',
                _children,
            '</custom>'
        );
    }

    //(gas: 94189)
    function testNestingComplex() public {

        function (string memory, string memory) pure returns (string memory) customHTMLThing = clunkyCustomHTMLThing;

        Callback memory callbackOutermost = _callBackbuilder('class="outermostProp"', "outermostClient", FunctionCoder.encode(HTML.div), 3);
        Callback memory callbackLeveltitle = _callBackbuilder("1a", FunctionCoder.encode(HTML.title), 0);
        Callback memory callbackLevel1a = _callBackbuilder('class="level1"', "1a", FunctionCoder.encode(HTML.div), 1);
        Callback memory callbackLevel2a = _callBackbuilder('class="level2"', "2a", FunctionCoder.encode(HTML.p), 0);
        Callback memory callbackLevel1b = _callBackbuilder('class="level1"', "1b", FunctionCoder.encode(HTML.h2), 1);
        Callback memory callbackLevel2b = _callBackbuilder('class="level2"', "2b", FunctionCoder.encode(HTML.div), 2);
        Callback memory callbackLevel3b1 = _callBackbuilder('class="level3"', "3b1", FunctionCoder.encode(HTML.p), 0);
        Callback memory callbackLevel3b2 = _callBackbuilder('class="level3"', "3b2", FunctionCoder.encode(HTML.p), 1);
        Callback memory callbackLevel3b2a = _callBackbuilder('id="because we can"', "never ask, just do", FunctionCoder.encode(customHTMLThing), 0);

        callbackOutermost.addToNest(0, callbackLeveltitle);
        callbackLevel1a.addToNest(0, callbackLevel2a);
        callbackOutermost.addToNest(1, callbackLevel1a);
        callbackLevel3b2.addToNest(0, callbackLevel3b2a);
        callbackLevel2b.addToNest(1, callbackLevel3b2);
        callbackLevel2b.addToNest(0, callbackLevel3b1);
        callbackLevel1b.addToNest(0, callbackLevel2b);
        callbackOutermost.addToNest(2, callbackLevel1b);

        string memory result = callbackOutermost.readNest();

        string memory expected = string.concat(
            '<div class="outermostProp">outermostClient',
                '<title>1a</title>'
                '<div class="level1">1a',
                    '<p class="level2">2a</p>',
                '</div>',
                '<h2 class="level1">1b',
                    '<div class="level2">2b',
                        '<p class="level3">3b1</p>',
                        '<p class="level3">3b2',
                            '<custom id="because we can">never ask, just do</custom>',
                        '</p>',
                    '</div>',
                '</h2>',
            '</div>'
        );
        emit log_string(result);
        assertEq(result, expected, "Nesting failed");
    }

    //(gas: 15013)
    function testNestingWithLibsOnly() public {
        string memory result;

        result = string.concat(
            HTML.div(
                'class="outermostProp"', 
                string.concat(
                    'outermostClient',
                    HTML.title('1a'),
                    HTML.div(
                        'class="level1"', 
                        string.concat(
                            '1a',
                            HTML.p('class="level2"', '2a')
                        )
                    ),
                    HTML.h2(
                        'class="level1"', 
                        string.concat(
                            '1b',
                            HTML.div(
                                'class="level2"', 
                                string.concat(
                                    '2b',
                                    HTML.p('class="level3"', '3b1'),
                                    HTML.p('class="level3"', 
                                        string.concat(
                                            '3b2',
                                            HTML.el('custom','id="because we can"', 'never ask, just do')
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        );



    }



}
