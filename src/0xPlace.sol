// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { PlaceToken } from "./PlaceToken.sol";
import { Ownable, SafeTransferLib } from "lib/solady/src/Milady.sol";

interface IURIProvider {
    function read() external view returns (string memory);
}

interface IUIProvider {
    function renderUI(bytes memory pixels) external view returns (string memory);
}

contract zeroxPlace is IURIProvider, Ownable {
    PlaceToken public immutable token;
    uint public constant MAX_PIXELS = 262_144; //512*512
    
    IUIProvider public uiProvider;
    bool public freezeUiProvider = false;

    bytes public canvas; // 512x512 canvas
    mapping(uint256 => address) public pixelOwner; // pixel index => owner

    error CLAIMED();
    error INSUFFICIENT_PAYMENT();
    error LIMIT_EXCEEDED();
    error INVALID_COLOR();
    error UNBALANCE_ARRAY();
    error OUT_OF_BOUNDS();

    event PixelColorChanged(uint256 indexed index, uint8 color);
    event PixelColorChanged(uint256[] indexed index, uint8[] color);

    constructor() {
        token = new PlaceToken();
        _initializeOwner(msg.sender);
        _fakeERC721();
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ERC721 fake stuff | We lie about being an ERC721 so that Opensea can index us.
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    // this contract isn't really an NFT, but we're faking it for Opensea to index it.
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    function ownerOf(uint256 tokenId) public view returns (address) {
        return tokenId == 0 ? owner() : address(0);
    }

    function balanceOf(address owner) public view returns (uint256) {
        address _owner = Ownable.owner();
        return owner == _owner ? 1 : 0;
    }

    function _fakeERC721() internal {
        emit Transfer(address(0), msg.sender, 0);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////


    function read() external view override returns (string memory) {
        return "https://0xplace.com/api/";
    }

    // the user can claim pixels, and receive 100 PLACE tokens per pixel claimed
    function claimPixel() public payable {
        if (canvas.length == MAX_PIXELS) revert CLAIMED();
        if (msg.value != 0.0001 ether) revert INSUFFICIENT_PAYMENT();

        canvas.push(0x00); // create a new pixel
        pixelOwner[canvas.length - 1] = msg.sender; // set the owner of the pixel
        token.transfer(msg.sender, 100 * 1e18); // transfer 100 PLACE tokens to the user
    }

    // multiclaim for pixels, with 100 pixel limit
    function claimPixel(uint256 number) public payable {
        if (canvas.length == MAX_PIXELS) revert CLAIMED();
        if (number > 100) revert LIMIT_EXCEEDED();
        if (msg.value != 0.0001 ether * number) revert INSUFFICIENT_PAYMENT();
        uint256 _number;
        if (canvas.length + number > MAX_PIXELS) {
            _number = MAX_PIXELS - canvas.length;
        } else {
            _number = number;
        }

        unchecked {
            for (uint256 i = 0; i < _number; i++) {
                canvas.push(0x00); // create a new pixel
                pixelOwner[canvas.length - 1] = msg.sender; // set the owner of the pixel
            }
        }

        token.transfer(msg.sender, _number * 100 * 1e18);
    }

    function draw(uint256 index, uint8 color) public {
        if (color > 215) revert INVALID_COLOR();
        if (index > MAX_PIXELS) revert OUT_OF_BOUNDS();
        
        token.transferFrom(msg.sender, pixelOwner[index], 1e18); // transfer 1 PLACE token to the current owner of the pixel
        pixelOwner[index] = msg.sender; // set msg.sender as the new owner of the pixel
        canvas[index] = bytes1(color);

        emit PixelColorChanged(index, color);
    }

    function draw(uint256[] memory indexes, uint8[] memory colors) public {
        if (indexes.length != colors.length) revert UNBALANCE_ARRAY();
        

        uint len = indexes.length;

        unchecked{
            for (uint256 i = 0; i < len; i++) {
                if (indexes[i] > MAX_PIXELS) revert OUT_OF_BOUNDS();
                if (colors[i] > 215) revert INVALID_COLOR();
                token.transferFrom(msg.sender, pixelOwner[indexes[i]], 1e18); // transfer 1 PLACE token to the current owner of the pixel
                pixelOwner[indexes[i]] = msg.sender; // set msg.sender as the new owner of the pixel
                canvas[indexes[i]] = bytes1(colors[i]);
            }
        }

        emit PixelColorChanged(indexes, colors);
    }

    /// @dev Returns true if this contract implements the interface defined by `interfaceId`.
    /// See: https://eips.ethereum.org/EIPS/eip-165
    /// This function call must use less than 30000 gas.
    /// @dev Returns true for ERC721 to ensure pickup by OpenSea and marketplaces
    function supportsInterface(bytes4 interfaceId) public view returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let s := shr(224, interfaceId)
            // ERC165: 0x01ffc9a7, ERC721: 0x80ac58cd, ERC721Metadata: 0x5b5e139f, URIProvider: 57de26a4.
            result := or(or(or(eq(s, 0x01ffc9a7), eq(s, 0x80ac58cd)), eq(s, 0x5b5e139f)), eq(s, 0x57de26a4))
        }
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferETH(msg.sender, address(this).balance);
    }

    function setUIProvider(address _uiProvider) public onlyOwner {
        require(!freezeUiProvider, "UI provider is frozen");
        uiProvider = IUIProvider(_uiProvider);
    }

    function freezeUIProvider() public onlyOwner {
        freezeUiProvider = true;
    }
}
