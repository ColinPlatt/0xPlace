// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString, ExtLibString} from "../utils/ExtLibString.sol";
import {FunctionCoder} from "../utils/FunctionCoder.sol";

struct childCallback {
    string prop;
    string child;
    function (string memory, string memory) pure returns (string memory) callback;
}

struct childCallback_ {
    string prop;
    function (string memory) pure returns (string memory) callback;
}

struct html {
    string head;
    string body;
}

struct Callback {
    string[] inputs; // inputs for this level (ordering level _tag > _props > _children)
    bytes32 callbackFn; // HTML coding function for this level
    bytes[] children; // encoded (nested) children. Must be initialized before use.
    string decoded; // decoded result of this level
}

/* HTML NESTING OPERATIONS */

function addToNest(Callback memory _parentCallback, uint256 childIndex, Callback memory _childCallback) pure {
    if(!_hasChildren(_childCallback)) {
        _getDecodeFnResult(_parentCallback, _childCallback);
        _parentCallback.children[childIndex] = abi.encode(0); // zero out child
    } else {
        _parentCallback.children[childIndex] = abi.encode(_childCallback);
    }
}

function _hasChildren(Callback memory _callback) pure returns (bool) {
    return _callback.children.length > 0;
}

function _getDecodeFnResult(Callback memory _callback) pure {
    
    if (_callback.inputs.length == 1) {
        _callback.decoded = FunctionCoder.decode(_callback.callbackFn, _callback.inputs[0]);
    } else if (_callback.inputs.length == 2) {
        _callback.decoded = FunctionCoder.decode(_callback.callbackFn, _callback.inputs[0], _callback.inputs[1]);
    } else if (_callback.inputs.length == 3) {
        _callback.decoded =  FunctionCoder.decode(_callback.callbackFn, _callback.inputs[0], _callback.inputs[1], _callback.inputs[2]);
    } else {
        _callback.decoded =  "Err: could not decode function result";
    }
}

function _getDecodeFnResult(Callback memory _parentCallback, Callback memory _childCallback) pure {
    
    uint256 input_position = _parentCallback.inputs.length - 1;

    string memory result;    

    if (_childCallback.inputs.length == 1) {
        result = FunctionCoder.decode(_childCallback.callbackFn, _childCallback.inputs[0]);
    } else if (_childCallback.inputs.length == 2) {
        result = FunctionCoder.decode(_childCallback.callbackFn, _childCallback.inputs[0], _childCallback.inputs[1]);
    } else if (_childCallback.inputs.length == 3) {
        result =  FunctionCoder.decode(_childCallback.callbackFn, _childCallback.inputs[0], _childCallback.inputs[1], _childCallback.inputs[2]);
    } else {
        result =  "Err: could not decode function result";
    }

    _parentCallback.inputs[input_position] = LibString.concat(_parentCallback.inputs[input_position], result);
}


function _stringLen(string memory _str) pure returns (uint256) {
    uint256 len;
    assembly {
        len := mload(_str)
    }
    return len;
}

function _stepIntoChild(Callback memory _callback) pure {
    for (uint256 i = 0; i < _callback.children.length; i++) {
        if(keccak256(_callback.children[i]) != keccak256(abi.encode(0))) {
            Callback memory _child = abi.decode(_callback.children[i], (Callback));
            _stepIntoChild(_child);
            //if the child has decoded content, we need to add it to the current level's inputs
            if (_stringLen(_child.decoded) != 0) {
                _callback.decoded = LibString.concat(_callback.decoded, _child.decoded);
            }
        }
    }

    uint256 input_position = _callback.inputs.length - 1;

    _callback.inputs[input_position] = LibString.concat(_callback.inputs[input_position], _callback.decoded);

    _getDecodeFnResult(_callback);
}

function readNest(Callback memory _callback) pure returns (string memory result) {
    _stepIntoChild(_callback);

    return _callback.decoded;
}

using {addToNest, readNest} for Callback global;

/* HTML STRUCTURE OPERATIONS */
function read(html memory _html) pure returns (string memory) {
    return string.concat("<!DOCTYPE html><html><head>", _html.head, "</head><body>", _html.body, "</body></html>");
}

function appendHead(html memory _html, string memory _head) pure {
    _html.head = LibString.concat(_html.head, _head);
}

function prependHead(html memory _html, string memory _head) pure {
    _html.head = LibString.concat(_head, _html.head);
}

function appendBody(html memory _html, string memory _body) pure {
    _html.body = LibString.concat(_html.body, _body);
}

function prependBody(html memory _html, string memory _body) pure {
    _html.body = LibString.concat(_body, _html.body);
}

/* MAIN ELEMENTS */
function title(html memory _html, string memory _title) pure {
    _html.appendHead(el("title", _title));
}

function meta(html memory _html, string memory _meta) pure {
    _html.appendHead(el("title", _meta));
}

function style(html memory _html, string memory _style) pure {
    _html.appendHead(el("style", _style));
}

function div(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("div", _props, _children));
}

function div_(html memory _html, string memory _children) pure {
    _html.appendBody(el("div", _children));
}

function divOpen(html memory _html, string memory _props) pure {
    _html.appendBody(elOpen("div", _props));
}

function divOpen_(html memory _html) pure {
    _html.appendBody(elOpen("div"));
}

function divClose(html memory _html) pure {
    _html.appendBody(elClose("div"));
}

function divChild(html memory _html, string memory _props, childCallback memory _childCallback) pure {
    _html.appendBody(elCallBack("div", _props, _childCallback));
}

function divChildRecursive(
    html memory _html,
    string memory _propsOutermost,
    childCallback memory _childCallbackOuter,
    childCallback memory _childCallbacksInner
) pure {
    _html.appendBody(elCallBackRecursive("div", _propsOutermost, _childCallbackOuter, _childCallbacksInner));
}

function elCallBackRecursive(
    string memory _tagOutermost,
    string memory _propsOutermost,
    childCallback memory _childCallbackOuter,
    childCallback memory _childCallbacksInner
) pure returns (string memory) {
    return string.concat(
        "<",
        _tagOutermost,
        " ",
        _propsOutermost,
        ">",
        _childCallbackOuter.callback(
            _childCallbackOuter.prop,
            _childCallbacksInner.callback(_childCallbacksInner.prop, _childCallbacksInner.child)
        ),
        "</",
        _tagOutermost,
        ">"
    );
}

function divChildren(html memory _html, string memory _props, childCallback[] memory _childCallbacks) pure {
    _html.appendBody(elCallBack("div", _props, _childCallbacks));
}

function divChild_(html memory _html, string memory _props, childCallback_ memory _childCallback) pure {
    _html.appendBody(elCallBack("div", _props, _childCallback));
}

function divChildren_(html memory _html, string memory _props, childCallback_[] memory _childCallbacks) pure {
    _html.appendBody(elCallBack("div", _props, _childCallbacks));
}

function textarea(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("textarea", _props, _children));
}

function link(html memory _html, string memory _props, string memory _children) pure {
    _html.appendHead(el("link", _props, _children));
}

function link_(html memory _html, string memory _props) pure {
    _html.appendHead(elProp("link", _props));
}

function input(html memory _html, string memory _props) pure {
    _html.appendHead(elProp("input", _props));
}

function a(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("a", _props, _children));
}

function a_(html memory _html, string memory _children) pure {
    _html.appendBody(el("a", _children));
}

function p(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("p", _props, _children));
}

function p_(html memory _html, string memory _children) pure {
    _html.appendBody(el("p", _children));
}

function span(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("span", _props, _children));
}

function span_(html memory _html, string memory _children) pure {
    _html.appendBody(el("span", _children));
}

function button(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("button", _props, _children));
}

function button_(html memory _html, string memory _children) pure {
    _html.appendBody(el("button", _children));
}

function h1(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("h1", _props, _children));
}

function h1_(html memory _html, string memory _children) pure {
    _html.appendBody(el("h1", _children));
}

function h2(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("h2", _props, _children));
}

function h2_(html memory _html, string memory _children) pure {
    _html.appendBody(el("h2", _children));
}

function hN(html memory _html, uint256 _n, string memory _props, string memory _children) pure {
    _html.appendBody(el(LibString.concat("h", LibString.toString(_n)), _props, _children));
}

function hN_(html memory _html, uint256 _n, string memory _children) pure {
    _html.appendBody(el(LibString.concat("h", LibString.toString(_n)), _children));
}

function script(html memory _html, string memory _props, string memory _children) pure {
    _html.appendBody(el("script", _props, _children));
}

function script_(html memory _html, string memory _children) pure {
    _html.appendBody(el("script", _children));
}

/* COMMON */
// A generic element, can be used to construct any HTML element
function el(string memory _tag, string memory _props, string memory _children) pure returns (string memory) {
    return string.concat("<", _tag, " ", _props, ">", _children, "</", _tag, ">");
}

// A generic element, can be used to construct any HTML element without props
function el(string memory _tag, string memory _children) pure returns (string memory) {
    return string.concat("<", _tag, ">", _children, "</", _tag, ">");
}

function elOpen(string memory _tag, string memory _props) pure returns (string memory) {
    return string.concat("<", _tag, " ", _props, ">");
}

// A generic element, can be used to construct any HTML element without props
function elOpen(string memory _tag) pure returns (string memory) {
    return string.concat("<", _tag, ">");
}

function elClose(string memory _tag) pure returns (string memory) {
    return string.concat("</", _tag, ">");
}

// A generic element, can be used to construct any HTML element without children
function elProp(string memory _tag, string memory _prop) pure returns (string memory) {
    return string.concat("<", _tag, " ", _prop, "/>");
}

function elCallBack(string memory _tag, string memory _props, childCallback memory _childCallback)
    pure
    returns (string memory)
{
    return string.concat(
        "<", _tag, " ", _props, ">", _childCallback.callback(_childCallback.prop, _childCallback.child), "</", _tag, ">"
    );
}

function elCallBack(string memory _tag, string memory _props, childCallback_ memory _childCallback)
    pure
    returns (string memory)
{
    return string.concat("<", _tag, " ", _props, ">", _childCallback.callback(_childCallback.prop), "</", _tag, ">");
}

function elCallBack(string memory _tag, string memory _props, childCallback_[] memory _childCallback)
    pure
    returns (string memory)
{
    string memory _children;

    unchecked {
        for (uint256 i = 0; i < _childCallback.length; i++) {
            _children = LibString.concat(_children, _childCallback[i].callback(_childCallback[i].prop));
        }
    }

    return string.concat("<", _tag, " ", _props, ">", _children, "</", _tag, ">");
}

function elCallBack(string memory _tag, string memory _props, childCallback[] memory _childCallback)
    pure
    returns (string memory)
{
    string memory _children;

    unchecked {
        for (uint256 i = 0; i < _childCallback.length; i++) {
            _children =
                LibString.concat(_children, _childCallback[i].callback(_childCallback[i].prop, _childCallback[i].child));
        }
    }

    return string.concat("<", _tag, " ", _props, ">", _children, "</", _tag, ">");
}

// an HTML attribute
function prop(string memory _key, string memory _val) pure returns (string memory) {
    return string.concat(_key, "=", '"', _val, '" ');
}

using {read, appendHead, prependHead, appendBody, prependBody} for html global;

using {
    title,
    meta,
    style,
    div,
    div_,
    divChild,
    divChildren,
    divChild_,
    divChildren_,
    divChildRecursive,
    divOpen,
    divOpen_,
    divClose,
    textarea,
    link,
    link_,
    input,
    a,
    a_,
    p,
    p_,
    span,
    span_,
    button,
    button_,
    h1,
    h1_,
    h2,
    h2_,
    hN,
    hN_,
    script,
    script_
} for html global;
