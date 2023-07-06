// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString, ExtLibString} from "../utils/ExtLibString.sol";

struct fn {
    string _function;
}

/* FUNCTION STRUCTURE OPERATIONS */
function readFn(fn memory _fn) pure returns (string memory) {
    return _fn._function;
}

function appendFn(fn memory _fn, string memory _op) pure returns (fn memory) {
    _fn._function = LibString.concat(_fn._function, _op);
    return _fn;
}

function prependFn(fn memory _fn, string memory _op) pure returns (fn memory) {
    _fn._function = LibString.concat(_op, _fn._function);
    return _fn;
}

function initializeNamedFn(fn memory _fn, string memory _name) pure returns (fn memory) {
    _fn._function = string.concat("function ", _name, "()");
    return _fn;
}

function initializeNamedArgsFn(fn memory _fn, string memory _name, string memory _args) pure returns (fn memory) {
    _fn._function = string.concat("function ", _name, "(", _args, ")");
    return _fn;
}

function initializeFn(fn memory _fn) pure returns (fn memory) {
    _fn._function = "function()";
    return _fn;
}

function initializeArgsFn(fn memory _fn, string memory _args) pure returns (fn memory) {
    _fn._function = string.concat("function(", _args, ")");
    return _fn;
}

function asyncFn(fn memory _fn) pure returns (fn memory) {
    _fn = _fn.prependFn("async ");
    return _fn;
}

function bodyFn(fn memory _fn, string memory _body) pure returns (fn memory) {
    _fn = _fn.appendFn(string.concat("{", _body, "}"));
    return _fn;
}

using {
    readFn,
    appendFn,
    prependFn,
    initializeNamedFn,
    initializeNamedArgsFn,
    initializeFn,
    initializeArgsFn,
    asyncFn,
    bodyFn
} for fn global;

enum ArrowFn {
    Const,
    Var,
    Let
}

function getArrowFnType(ArrowFn _type) pure returns (string memory) {
    if (_type == ArrowFn.Const) {
        return "const ";
    } else if (_type == ArrowFn.Var) {
        return "var ";
    } else {
        return "let ";
    }
}

struct arrowFn {
    string _function;
}

/* ARROW FUNCTION STRUCTURE OPERATIONS */
function readArrowFn(arrowFn memory _arrowFn) pure returns (string memory) {
    return _arrowFn._function;
}

function appendArrowFn(arrowFn memory _arrowFn, string memory _op) pure returns (arrowFn memory) {
    _arrowFn._function = LibString.concat(_arrowFn._function, _op);
    return _arrowFn;
}

function prependArrowFn(arrowFn memory _arrowFn, string memory _op) pure returns (arrowFn memory) {
    _arrowFn._function = LibString.concat(_op, _arrowFn._function);
    return _arrowFn;
}

function initializeNamedArrowFn(arrowFn memory _arrowFn, ArrowFn _type, string memory _name)
    pure
    returns (arrowFn memory)
{
    _arrowFn._function = string.concat(getArrowFnType(_type), _name, " = () => ");
    return _arrowFn;
}

function initializeNamedArgsArrowFn(arrowFn memory _arrowFn, ArrowFn _type, string memory _name, string memory _args)
    pure
    returns (arrowFn memory)
{
    _arrowFn._function = string.concat(getArrowFnType(_type), _name, " = (", _args, ") => ");
    return _arrowFn;
}

function initializeArrowFn(arrowFn memory _arrowFn) pure returns (arrowFn memory) {
    _arrowFn._function = "() => ";
    return _arrowFn;
}

function initializeArgsArrowFn(arrowFn memory _arrowFn, string memory _args) pure returns (arrowFn memory) {
    _arrowFn._function = string.concat("(", _args, ") => ");
    return _arrowFn;
}

function asyncArrowFn(arrowFn memory _arrowFn) pure returns (arrowFn memory) {
    _arrowFn = _arrowFn.prependArrowFn("async ");
    return _arrowFn;
}

function initializeNamedAsyncArrowFn(arrowFn memory _arrowFn, ArrowFn _type, string memory _name)
    pure
    returns (arrowFn memory)
{
    _arrowFn._function = string.concat(getArrowFnType(_type), _name, " = async () => ");
    return _arrowFn;
}

function initializeNamedAsyncArgsArrowFn(
    arrowFn memory _arrowFn,
    ArrowFn _type,
    string memory _name,
    string memory _args
) pure returns (arrowFn memory) {
    _arrowFn._function = string.concat(getArrowFnType(_type), _name, " = async (", _args, ") => ");
    return _arrowFn;
}

function bodyArrowFn(arrowFn memory _arrowFn, string memory _body) pure returns (arrowFn memory) {
    _arrowFn = _arrowFn.appendArrowFn(string.concat("{", _body, "}"));
    return _arrowFn;
}

using {
    readArrowFn,
    appendArrowFn,
    prependArrowFn,
    initializeNamedArrowFn,
    initializeNamedArgsArrowFn,
    initializeArrowFn,
    initializeArgsArrowFn,
    asyncArrowFn,
    initializeNamedAsyncArrowFn,
    initializeNamedAsyncArgsArrowFn,
    bodyArrowFn
} for arrowFn global;
