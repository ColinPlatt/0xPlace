// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/0xPlace.sol";

contract zeroxPlaceScript is Script {
    zeroxPlace public place;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
            place = new zeroxPlace();
            place.claimPixel{value: 0.0001 ether * 100}(100);
        vm.stopBroadcast();
    }
}

// 0xPlace: 0x1dc05fbf9db32e909889859c9192afd2b30fa814
// PlaceToken: 0xD8916482B847eE55e7467B2C13587D1551Ed987d

//forge script script/0xPlace.s.sol:zeroxPlaceScript --rpc-url $RPC_URL_GOERLI --broadcast --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY --chain 5 --slow --verify -vvvv