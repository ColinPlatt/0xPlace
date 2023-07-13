// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LibString} from "lib/solady/src/Milady.sol";
import {FunctionCoder} from "../utils/FunctionCoder.sol";

library nestDispatcher {

    function addToNest(Callback_2 memory _parentCallback_2, Callback_2 memory _childCallback_2) internal pure returns (Callback_2 memory) {
        return _parentCallback_2.addToNest_1(_childCallback_2);
    }

    function addToNest(Callback_2 memory _parentCallback_2, Callback_2 memory _lchildCallback_2, Callback_2 memory _rchildCallback_2) internal pure returns (Callback_2 memory) {
        return _parentCallback_2.addToNest_2(_lchildCallback_2, _rchildCallback_2);
    }

    function addToNest(Callback_2 memory _parentCallback_2, Callback_2 memory _lchildCallback_2, Callback_2 memory _mchildCallback_2, Callback_2 memory _rchildCallback_2) internal pure returns (Callback_2 memory) {
        return _parentCallback_2.addToNest_3(_lchildCallback_2, _mchildCallback_2, _rchildCallback_2);
    }

}

struct Callback_2 {
    string[] inputs; // inputs for this level (ordering level _tag > _props > _children)
    bytes32 callbackFn; // HTML coding function for this level
    bytes[] children; // encoded (nested) children. Must be initialized before use.
    string decoded; // decoded result of this level
}

/* HTML NESTING OPERATIONS */

function _append(Callback_2 memory parent, uint idx, Callback_2 memory child) pure {
    if(!_hasChildren_2(child)) {
        _getDecodeFnResult_2(parent, child);
        parent.children[idx] = abi.encode(0); // zero out child
    } else {
        parent.children[idx] = abi.encode(child);
    }
}

function addToNest_1(Callback_2 memory _parentCallback_2, Callback_2 memory _childCallback_2) pure returns (Callback_2 memory) {
    _append(_parentCallback_2, 0, _childCallback_2);
    return _parentCallback_2;
}


function addToNest_2(
    Callback_2 memory _parentCallback_2, 
    Callback_2 memory _lchildCallback_2, 
    Callback_2 memory _rchildCallback_2
) pure returns (Callback_2 memory) {
    _append(_parentCallback_2, 0, _lchildCallback_2);
    _append(_parentCallback_2, 1, _rchildCallback_2);
    return _parentCallback_2;
}

function addToNest_3(
    Callback_2 memory _parentCallback_2, 
    Callback_2 memory _lchildCallback_2,
    Callback_2 memory _mchildCallback_2, 
    Callback_2 memory _rchildCallback_2
) pure returns (Callback_2 memory) {
    _append(_parentCallback_2, 0, _lchildCallback_2);
    _append(_parentCallback_2, 1, _mchildCallback_2);
    _append(_parentCallback_2, 2, _rchildCallback_2);
    return _parentCallback_2;
}


function _hasChildren_2(Callback_2 memory _callback) pure returns (bool) {
    return _callback.children.length > 0;
}

function _getDecodeFnResult_2(Callback_2 memory _callback) pure {
    
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

function _getDecodeFnResult_2(Callback_2 memory _parentCallback_2, Callback_2 memory _childCallback_2) pure {
    
    uint256 input_position = _parentCallback_2.inputs.length - 1;

    string memory result;    

    if (_childCallback_2.inputs.length == 1) {
        result = FunctionCoder.decode(_childCallback_2.callbackFn, _childCallback_2.inputs[0]);
    } else if (_childCallback_2.inputs.length == 2) {
        result = FunctionCoder.decode(_childCallback_2.callbackFn, _childCallback_2.inputs[0], _childCallback_2.inputs[1]);
    } else if (_childCallback_2.inputs.length == 3) {
        result =  FunctionCoder.decode(_childCallback_2.callbackFn, _childCallback_2.inputs[0], _childCallback_2.inputs[1], _childCallback_2.inputs[2]);
    } else {
        result =  "Err: could not decode function result";
    }

    _parentCallback_2.inputs[input_position] = LibString.concat(_parentCallback_2.inputs[input_position], result);
}


function _stringLen_2(string memory _str) pure returns (uint256) {
    uint256 len;
    assembly {
        len := mload(_str)
    }
    return len;
}

function _stepIntoChild_2(Callback_2 memory _callback) pure {
    for (uint256 i = 0; i < _callback.children.length; i++) {
        if(keccak256(_callback.children[i]) != keccak256(abi.encode(0))) {
            Callback_2 memory _child = abi.decode(_callback.children[i], (Callback_2));
            _stepIntoChild_2(_child);
            //if the child has decoded content, we need to add it to the current level's inputs
            if (_stringLen_2(_child.decoded) != 0) {
                _callback.decoded = LibString.concat(_callback.decoded, _child.decoded);
            }
        }
    }

    uint256 input_position = _callback.inputs.length - 1;

    _callback.inputs[input_position] = LibString.concat(_callback.inputs[input_position], _callback.decoded);

    _getDecodeFnResult_2(_callback);
}

function readNest_2(Callback_2 memory _callback) pure returns (string memory result) {
    _stepIntoChild_2(_callback);

    return _callback.decoded;
}

using {addToNest_1, addToNest_2, addToNest_3, readNest_2} for Callback_2 global;

