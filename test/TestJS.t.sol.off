// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/types/js.sol";

contract fnTest is Test {
    function testInitializeFn() public {
        fn memory newfn;
        newfn.initializeFn();
        assertEq(newfn.readFn(), "function()");

        fn memory newfn2;
        newfn2.initializeArgsFn("a, b");
        assertEq(newfn2.readFn(), "function(a, b)");

        fn memory newfn3;
        newfn3.initializeNamedFn("test");
        assertEq(newfn3.readFn(), "function test()");

        fn memory newfn4;
        newfn4.initializeNamedArgsFn("test", "a, b");
        assertEq(newfn4.readFn(), "function test(a, b)");

        fn memory newAsyncfn;
        newAsyncfn.initializeNamedArgsFn("test", "a, b");
        newAsyncfn.asyncFn();
        assertEq(newAsyncfn.readFn(), "async function test(a, b)");
    }

    function testBuildFn() public {
        fn memory newfn;
        newfn.initializeFn();
        newfn.bodyFn("console.log('hello world');");
        assertEq(newfn.readFn(), "function(){console.log('hello world');}");
    }

    function testInitializeArrowFn() public {
        arrowFn memory newArrowfn;
        newArrowfn.initializeArrowFn();
        assertEq(newArrowfn.readArrowFn(), "() => ");

        arrowFn memory newArrowfn2;
        newArrowfn2.initializeArgsArrowFn("a, b");
        assertEq(newArrowfn2.readArrowFn(), "(a, b) => ");

        arrowFn memory newArrowfn3;
        newArrowfn3.initializeNamedArrowFn(ArrowFn.Const, "test");
        assertEq(newArrowfn3.readArrowFn(), "const test = () => ");

        arrowFn memory newArrowfn4;
        newArrowfn4.initializeNamedArgsArrowFn(ArrowFn.Let, "test", "a, b");
        assertEq(newArrowfn4.readArrowFn(), "let test = (a, b) => ");

        arrowFn memory newAsyncArrowfn;
        newAsyncArrowfn.initializeNamedAsyncArgsArrowFn(ArrowFn.Var, "test", "a, b");
        assertEq(newAsyncArrowfn.readArrowFn(), "var test = async (a, b) => ");

        arrowFn memory newAsyncArrowfn2;
        newAsyncArrowfn2.initializeNamedAsyncArrowFn(ArrowFn.Var, "test");
        assertEq(newAsyncArrowfn2.readArrowFn(), "var test = async () => ");
    }

    function testBuildArrowFn() public {
        arrowFn memory newArrowfn;
        newArrowfn.initializeArrowFn();
        newArrowfn.bodyArrowFn("console.log('hello world');");
        assertEq(newArrowfn.readArrowFn(), "() => {console.log('hello world');};");
    }
}
