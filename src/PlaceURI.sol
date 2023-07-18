// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {WebSafeColors} from "./utils/WebSafeColors.sol";
import "./types/vu3.sol";
import {libBrowserProvider, libJsonRPCProvider} from "./utils/libBrowserProvider.sol";
import {LibString} from "lib/solady/src/Milady.sol";
import {Base64} from "lib/solady/src/utils/Base64.sol";
import {HTML} from "./utils/HTML.sol";
import {PlaceCSS} from "./PlaceCSS.sol";

contract UIProvider {
    using HTML for string;
    PlaceCSS public placeCSS;
    PlaceScripts public placeScripts;
    PlaceEthersScripts public placeEthersScripts;

    address public constant PLACE_ADDRESS = 0x1dC05fBf9db32e909889859C9192aFD2B30Fa814;
    address public constant PLACE_TOKEN = 0xD8916482B847eE55e7467B2C13587D1551Ed987d;

    // might need to move this to an initializer
    constructor() {
        placeCSS = new PlaceCSS();
        placeScripts = new PlaceScripts();
        placeEthersScripts = new PlaceEthersScripts();
    }

    function _getBody(html memory _page, bytes memory _pixels) internal view {
        PlaceBody._getHeaderBar(_page);
        PlaceBody._getInfoDiv(_page);    
        PlaceBody._getContainer(_page);
        _page.appendBody(ethersConnection.iframeFallback());
        _page.script_(ethersConnection.connectionLogic('web3-container'));
        _page.script_(placeEthersScripts.tokenApproval(PLACE_ADDRESS, PLACE_TOKEN));
        _page.script_(string.concat(
            'const ZEROxPLACE = "', LibString.toHexString(PLACE_ADDRESS), '"; ',
            'const PLACE_TOKEN = "', LibString.toHexString(PLACE_TOKEN), '";'
        ));
        _page.script_(placeScripts._getScripts(_pixels));
    }

    function _getPage(html memory _page, bytes memory _pixels) internal view returns (string memory) {
        _page.title("0xPlace");
        _page.style(placeCSS._getCSS());
        _getBody(_page, _pixels);

        return _page.read();
    }

    function renderUI(bytes memory pixels) external view returns (string memory) {
        html memory page; // initialize a new html page

        return _getPage(page, pixels);
    }
}

library PlaceBody {
    using HTML for string;
    using nestDispatcher for Callback;
    using nestDispatcher for string;


    function _getHeaderBar(html memory _page) internal pure {
        _page.appendBody(
            string("id").prop("header-bar").callBackbuilder('', HTML.div, 2).addToNest(
                string("class").prop("title").callBackbuilder('0xPlace', HTML.div, 0),
                ethersConnection.walletButtons()
            ).readNest()
        );
    }

    function _getInfoDiv(html memory _page) internal pure {
        childCallback_ memory infoChildren;

        infoChildren = childCallback_(
            "0xPlace is an entirely onchain canvas that lets users claim and update pixels. When a pixel is first claimed (0.0001 ETH each), the user receives 1000 $PLACE tokens. Each change requires 1 $PLACE token which is paid to the current owner of the pixel.",
            HTML.p_
        );

        _page.divChild_(string("id").prop("info"), infoChildren);
    }

    function _getContainer(html memory _page) internal pure {
        _page.appendBody(
            string("id").prop("web3-container").callBackbuilder('', HTML.div, 2).addToNest(
                string("id").prop("button-container").callBackbuilder('', HTML.div, 1).addToNest(
                    string("id").prop("pixel-art-options").callBackbuilder('', HTML.div, 5).addToNest(
                        string("id").prop("update-btn").callBackbuilder("Update", HTML.button, 0),
                        string("id").prop("eraser-btn").callBackbuilder("Erase", HTML.button, 0),
                        string("id").prop("color-selector-container").callBackbuilder('', HTML.div, 2).addToNest(
                            string("style").prop("margin:1rem 0.25rem 0;").callBackbuilder("Select Color", HTML.p, 0),
                            string.concat(
                                string("type").prop("color"),
                                string("id").prop("color-picker"),
                                string("value").prop("#ffffff")
                            ).callBackbuilder(HTML.input_, 0)
                        ),
                        string("id").prop("mint-btn").callBackbuilder("Mint", HTML.button, 0),
                        string("id").prop("color-btn").callBackbuilder("Color", HTML.button, 0)
                    )
                ),
                string.concat(
                    string("id").prop("pixel-art-area"),
                    string("oncontextmenu").prop("return false;")
                ).callBackbuilder('', HTML.div, 0)
            ).readNest()
        );
    }
}

// we place the elements in a separate contracts to avoid the spurious dragon

library ethersConnection {
    using HTML for string;

    function iframeFallback() internal pure returns (string memory) {
        return '<div class="iframe-fallback"><span class="body">Please open original media to enable Web3 features</span></div>';
    }

    function walletButtons() internal pure returns (Callback memory walletBtns) {
        walletBtns.decoded = '<div class="top-right"><div class="dot"></div><button class="connect-button">Connect Wallet</button><button class="switch-button">Switch Networks</button></div>';
    }

    struct ChainInfo{
        string chainName;
        string chainId;
        string rpcUrl;
        string blockExplorer;
        string nativeCurrencyName;
        string nativeCurrencySymbol;
        string nativeCurrencyDecimals;
    }

    function _chainInfoToString(ChainInfo memory _chainInfo) private pure returns (string memory) {
        return string.concat(
            '{ chainId: "', 
                _chainInfo.chainId, 
                '", chainName: "', 
                _chainInfo.chainName, 
                '", rpcUrls: ["', 
                _chainInfo.rpcUrl, 
                '"], blockExplorerUrls: ["', 
                _chainInfo.blockExplorer, 
                '"], nativeCurrency: { name: "',
                     _chainInfo.nativeCurrencyName, 
                     '", symbol: "', 
                     _chainInfo.nativeCurrencySymbol, 
                     '", decimals: ', 
                     _chainInfo.nativeCurrencyDecimals,
            ' } }'
        );
    }

    function connectionLogic(string memory web3Container) internal view returns (string memory) {

        ChainInfo memory _chainInfo = ChainInfo(
            "Goerli",
            "0x5", //LibString.toMinimalHexString(block.chainid),
            "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
            "https://goerli.etherscan.io/",
            "Goerli ETH",
            "ETH",
            "18"
        );

        /*
        if("0x5" === e) { (ethereum.enable().then(function (accounts) { setDotColor("green"); console.log(accounts); connectedAccount = accounts[0]; n.style.display = "none"; t.innerText = "Connected"; }).catch(console.error))} else {(setDotColor("red"), t.style.display = "none", n.style.display = "block")} }).catch(console.error)
        */

        return string.concat(
            'let isIframe; let provider; let accounts; let connectedAccount; function setDotColor(e) {document.querySelector(".dot").style.backgroundColor = e} document.addEventListener("DOMContentLoaded", function () {if (window == window.top) {provider = window.ethereum; isIframe = false; var e = document.getElementById("',
            web3Container,
            '", document.querySelector(".iframe-fallback").style.display = "none"),t = document.querySelector(".connect-button"), n = document.querySelector(".switch-button"); e.style.display = "block",',
            'void 0 !== provider ? (window.ethereum.request({method: "eth_requestAccounts"}), ethereum.request({method: "eth_accounts"}).then(function (accounts) {accounts.length === 0 ? (setDotColor("red"), t.style.display = "block", n.style.display = "none") : ethereum.request({method: "eth_chainId"}).then(function (e) {if("',
            _chainInfo.chainId,
            '" === e) { (ethereum.enable().then(function (accounts) { setDotColor("green"); console.log(accounts); connectedAccount = accounts[0]; n.style.display = "none"; t.innerText = "Connected"; }).catch(console.error))} else {(setDotColor("red"), t.style.display = "none", n.style.display = "block")} }).catch(console.error)}).catch(console.error), t.addEventListener("click", function () {ethereum.request({method: "eth_requestAccounts"}).then(function (accounts) {if(accounts.length > 0) {setDotColor("green"); t.innerText = "Connected"; n.style.display = "none"; connectedAccount = accounts[0]; } else { ethereum.enable().then(function (accounts) { setDotColor("green"); console.log(accounts); connectedAccount = accounts[0]; n.style.display = "none"; t.innerText = "Connected";}).catch(console.error); } }).catch(console.error)}), n.addEventListener("click", function () {window.ethereum.request({ method: "wallet_addEthereumChain", params: [',
            _chainInfoToString(_chainInfo),
            ']}).then(function () {n.style.display = "none"; setDotColor("green")}).catch(console.error)})) : (setDotColor("red"), t.style.display = "block", n.style.display = "none")} else {document.querySelector(".iframe-fallback").style.display = "block"; document.getElementById("',
            web3Container,
            '").style.display = "none", isIframe = true;}});'
        );
    } 
}

interface IERC20{
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract PlaceEthersScripts {
    using HTML for string;

    function _getFormedTansaction(address _to, string memory _data) internal view returns (string memory) {

        return string.concat(
            '{',
                'to: "', LibString.toHexString(_to), '",'
                'data: "', _data,
            '"}'
        );
    }

    function _getFormedTansaction(string memory _from, address _to, string memory _data) internal view returns (string memory) {

        return string.concat(
            '{',
                'from: ', _from, ','
                'to: "', LibString.toHexString(_to), '",'
                'data: "', _data,
            '"}'
        );
    }

    function _getFormedTansaction(address _from, address _to, uint _value, string memory _data) internal view returns (string memory) {

        return string.concat(
            '{',
                'from: "', LibString.toHexString(_from), '",'
                'to: "', LibString.toHexString(_to), '",'
                'value: "', LibString.toMinimalHexString(_value), '",'
                'data: "', _data,
            '"}'
        );
    }

    // to avoid having to work with connected wallet addresses in JS we just write helper functions
    function getTokenApprovalAmount(address token, address spender) public view returns (uint) {
        return IERC20(token).allowance(msg.sender, spender);
    }

    function getTokenBalanceAmount(address token) public view returns (uint) {
        return IERC20(token).balanceOf(msg.sender);
    }

    function _balanceAndApproveTransactions(address place, address token) internal view returns (string memory allowanceCallTxn, string memory balanceCallTxn, string memory approvalTxn) {
        allowanceCallTxn = _getFormedTansaction(
            address(this),
            LibString.toHexString(abi.encodeWithSignature(
                "getTokenApprovalAmount(address,address)",
                token,
                place
            ))
        );

        balanceCallTxn = _getFormedTansaction(
            address(this),
            LibString.toHexString(abi.encodeWithSignature(
                "getTokenBalanceAmount(address)",
                token
            ))
        );

        approvalTxn = _getFormedTansaction(
            'connectedAccount',
            token,
            LibString.toHexString(abi.encodeWithSignature(
                "approve(address,uint256)",
                place,
                type(uint256).max
            ))
        );
    }

    function tokenApproval(address place, address token) public view returns (string memory) {
        fn memory _approvalFn;

        (string memory allowanceCallTxn, string memory balanceCallTxn, string memory approvalTxn) = _balanceAndApproveTransactions(place, token);

        _approvalFn.initializeFn();
        _approvalFn.asyncFn();
        _approvalFn.prependFn('colorButton.addEventListener("click", ');
            _approvalFn.openBodyFn();
                _approvalFn.appendFn('if(connectedAccount == undefined) {alert("Please connect your wallet first");} else {');
                    // get current allowance
                    _approvalFn.appendFn(string.concat('const allowance = await ', libBrowserProvider.ethereum_request(libJsonRPCProvider.eth_call(allowanceCallTxn, libJsonRPCProvider.blockTag.latest)), ';'));
                    // if current allowance is 0, then we need to approve
                    _approvalFn.appendFn('console.log("allowance:", allowance);');
                    _approvalFn.appendFn('if(allowance == "0x") {');
                        // get current balance
                        _approvalFn.appendFn(string.concat('const balance = await ', libBrowserProvider.ethereum_request(libJsonRPCProvider.eth_call(balanceCallTxn, libJsonRPCProvider.blockTag.latest)), ';'));
                        // if current balance is 0, then we need to approve
                        _approvalFn.appendFn('console.log("balance:", balance);');
                        _approvalFn.appendFn('if(balance == "0x") {');
                            // approve
                            _approvalFn.appendFn(string.concat('await ', libBrowserProvider.ethereum_request(libJsonRPCProvider.eth_sendTransaction(approvalTxn)), ';'));
                _approvalFn.appendFn('}}}');
            _approvalFn.closeBodyFn();
        _approvalFn.appendFn(');');
        

        return LibString.concat(
            'const colorButton = document.getElementById("color-btn");',
            _approvalFn.readFn()
        );
    }

}


contract PlaceScripts {
    using HTML for string;

    struct script {
        string scriptContent;
    }

    function _stateVars(script memory _script) internal pure {
        _script.scriptContent = string.concat(
            _script.scriptContent,
            'let state={config:{width:1024,height:1024,defaultColor:"#ffffff"},events:{mousedown:!1},colors:[],pixelArtArea:document.getElementById("pixel-art-area"),canvasArea:null,context:{},gridSize:2,currentStep:null,isStepComplete:!1,isLeftMouseDown:!1,isRightMouseDown:!1,dragStartX:0,dragStartY:0,dragOffsetX:0,dragOffsetY:0,zoomLevel:1,cursorSize:1,cursorHighlight:document.createElement("div"),indexedColors:"",mintButton:document.getElementById("mint-btn"),colorPicker:document.querySelector("#color-picker")};',
            "const { config, pixelArtArea, cursorHighlight, mintButton, colorPicker } = state;"
            "state.canvasArea = document.createElement('canvas');",
            "state.canvasArea.id = 'canvas-area';",
            "state.canvasArea.width = config.width;",
            "state.canvasArea.height = config.height;",
            "state.canvasArea.aspectRatio = config.width / config.height;",
            "state.context = state.canvasArea.getContext('2d');"
        );
    }

    function _forLoop(string memory _varName, string memory _length, string memory _body)
        private
        pure
        returns (string memory)
    {
        return string.concat(
            "for (let ", _varName, " = 0; ", _varName, " < ", _length, "; ", _varName, "++) {", _body, "}"
        );
    }

    function _forLoop(string memory _varName, string memory _length, string memory _increments, string memory _body)
        private
        pure
        returns (string memory)
    {
        return string.concat(
            "for (let ",
            _varName,
            " = 0; ",
            _varName,
            " <",
            _length,
            "; ",
            _varName,
            "+=",
            _increments,
            ") {",
            _body,
            "}"
        );
    }

    function _drawGrid(script memory _script) internal pure {
        arrowFn memory _drawGridFn;

        _drawGridFn.initializeNamedArrowFn(ArrowFn.Const, "drawGrid");
        _drawGridFn.openBodyArrowFn();
        _drawGridFn.appendArrowFn("if (isIframe) return;");
        _drawGridFn.appendArrowFn("state.context.strokeStyle = 'gray';");
        _drawGridFn.appendArrowFn("state.context.lineWidth = 0.1;");
        _drawGridFn.appendArrowFn(
            _forLoop(
                "x",
                "= state.canvasArea.width",
                "state.gridSize",
                string.concat(
                    "state.context.beginPath();" "state.context.moveTo(x, 0);"
                    "state.context.lineTo(x, state.canvasArea.height);" "state.context.stroke();"
                )
            )
        );

        _drawGridFn.appendArrowFn(
            _forLoop(
                "y",
                "= state.canvasArea.height",
                "state.gridSize",
                string.concat(
                    "state.context.beginPath();" "state.context.moveTo(0, y);"
                    "state.context.lineTo(state.canvasArea.width, y);" "state.context.stroke();"
                )
            )
        );
        _drawGridFn.appendArrowFn('pixelArtArea.appendChild(state.canvasArea);');
        _drawGridFn.closeBodyArrowFn();
        _drawGridFn.appendArrowFn("drawGrid();");

        _script.scriptContent = LibString.concat(_script.scriptContent, _drawGridFn.readArrowFn());
    }

    function _handleChange(script memory _script) internal pure {
        arrowFn memory _handleChangeFn;

        _handleChangeFn.initializeNamedArgsArrowFn(ArrowFn.Const, "handleChange", "x, y, pixelSize, color");
        _handleChangeFn.openBodyArrowFn();

        _handleChangeFn.appendArrowFn("if (state.currentStep !== null && ! state.isStepComplete) {");
        _handleChangeFn.appendArrowFn(
            _forLoop(
                "i",
                "pixelSize",
                string.concat(
                    'let pixelExists = false;',
                    _forLoop(
                        "j",
                        "state.currentStep.changes.length",
                        string.concat(
                            "if (state.currentStep.changes[j].x === x + i && state.currentStep.changes[j].y === y + i) {",
                            "state.currentStep.changes[j].color = color;",
                            "pixelExists = true;",
                            "break;}"
                        )
                    ),
                    string.concat(
                        "if (! pixelExists) {", "state.currentStep.changes.push({x: x + i, y: y + i, color: color});}}"
                    )
                )
            )
        );

        _handleChangeFn.closeBodyArrowFn();

        _script.scriptContent = LibString.concat(_script.scriptContent, _handleChangeFn.readArrowFn());
    }

    function _handleEraser(script memory _script) internal pure {
        arrowFn memory _handleEraserFn;

        _handleEraserFn.initializeNamedArrowFn(ArrowFn.Const, "handleEraser");
        _handleEraserFn.openBodyArrowFn();
        _handleEraserFn.appendArrowFn("if (state.currentStep !== null) {");
        _handleEraserFn.appendArrowFn(
            _forLoop(
                "i",
                "state.currentStep.changes.length",
                string.concat(
                    "const {x, y, color} = state.currentStep.changes[i];",
                    "state.currentStep.erasures.push({x, y, color});"
                )
            )
        );
        _handleEraserFn.appendArrowFn("state.currentStep.changes = [];}");
        _handleEraserFn.closeBodyArrowFn();

        _script.scriptContent = LibString.concat(_script.scriptContent, _handleEraserFn.readArrowFn());
    }

    function _handlePixelColor(script memory _script) internal pure {
        arrowFn memory _handlePixelColorFn;

        _handlePixelColorFn.initializeNamedArgsArrowFn(ArrowFn.Const, "handlePixelColor", "event");
        _handlePixelColorFn.openBodyArrowFn();
        _handlePixelColorFn.appendArrowFn("const pixelCanvas = state.canvasArea;");
        _handlePixelColorFn.appendArrowFn("const ctx = state.context;");
        _handlePixelColorFn.appendArrowFn("const rect = pixelCanvas.getBoundingClientRect();");
        _handlePixelColorFn.appendArrowFn("const pixelSize = state.gridSize;");
        _handlePixelColorFn.appendArrowFn("const offsetX = rect.left + window.scrollX * state.zoomLevel;");
        _handlePixelColorFn.appendArrowFn("const offsetY = rect.top + window.scrollY * state.zoomLevel;");
        _handlePixelColorFn.appendArrowFn("const x = Math.floor(event.offsetX / pixelSize);");
        _handlePixelColorFn.appendArrowFn("const y = Math.floor(event.offsetY / pixelSize);");
        _handlePixelColorFn.appendArrowFn("if (x > 512 || y > 512) return;");
        _handlePixelColorFn.appendArrowFn("const pixelIndex = y * 2 + x;");
        _handlePixelColorFn.appendArrowFn("ctx.fillStyle = state.activeColor;");
        _handlePixelColorFn.appendArrowFn(
            "ctx.fillRect(x * pixelSize, y * pixelSize, state.cursorSize, state.cursorSize);"
        );
        _handlePixelColorFn.appendArrowFn("handleChange(x, y, pixelSize, state.activeColor);");
        _handlePixelColorFn.closeBodyArrowFn();

        _script.scriptContent = LibString.concat(_script.scriptContent, _handlePixelColorFn.readArrowFn());
    }

    function _hexToRgb(script memory _script) internal pure {
        arrowFn memory _hexToRgbFn;

        _hexToRgbFn.initializeNamedArgsArrowFn(ArrowFn.Const, "hexToRgb", "hex");
        _hexToRgbFn.appendArrowFn(
            string.concat(
                "hex.slice(1).replace(/^(.)(.)(.)$/gi, '$1$1$2$2$3$3').match(/.{2}/g).map((c) => parseInt(c, 16));"
            )
        );

        _script.scriptContent = LibString.concat(_script.scriptContent, _hexToRgbFn.readArrowFn());
    }

    function _distance(script memory _script) internal pure {
        arrowFn memory _distanceFn;

        _distanceFn.initializeNamedArgsArrowFn(ArrowFn.Const, "distance", "a, b");
        _distanceFn.appendArrowFn(
            string.concat("Math.sqrt(Math.pow(a[0] - b[0], 2) + Math.pow(a[1] - b[1], 2) + Math.pow(a[2] - b[2], 2));")
        );

        _script.scriptContent = LibString.concat(_script.scriptContent, _distanceFn.readArrowFn());
    }

    function _nearestColor(script memory _script) internal pure {
        arrowFn memory _nearestColorFn;

        _nearestColorFn.initializeNamedArgsArrowFn(ArrowFn.Const, "nearestColor", "colorHex");
        _nearestColorFn.appendArrowFn(
            "state.colors.reduce((a, v, i, arr) => (a = distance(hexToRgb(colorHex), hexToRgb(v)) < a[0] ? ["
        );
        _nearestColorFn.appendArrowFn(
            "distance(hexToRgb(colorHex), hexToRgb(v)), v ] : a), [Number.POSITIVE_INFINITY, state.colors[0]])[1];"
        );

        _script.scriptContent = LibString.concat(_script.scriptContent, _nearestColorFn.readArrowFn());
    }

    function _getArrowFns(script memory _script) internal pure {
        _drawGrid(_script);
        _handleChange(_script);
        _handleEraser(_script);
        _handlePixelColor(_script);
        _hexToRgb(_script);
        _distance(_script);
        _nearestColor(_script);
    }

    function _setColors(script memory _script, bytes memory _pixels) internal pure {
        arrowFn memory _setColorsFn;

        _setColorsFn.initializeNamedArrowFn(ArrowFn.Const, "setColors");
        _setColorsFn.openBodyArrowFn();
        _setColorsFn.appendArrowFn(
            string.concat('const currentPixels = "', LibString.toHexStringNoPrefix(_pixels), '";')
        );
        _setColorsFn.appendArrowFn(
            _forLoop("i", "currentPixels.length", "state.indexedColors.push('#' + currentPixels.slice(i, i + 6));")
        );
        _setColorsFn.closeBodyArrowFn();

        _script.scriptContent = LibString.concat(_script.scriptContent, _setColorsFn.readArrowFn());
    }

    function _asyncSetPixelState(script memory _script) internal pure {
        fn memory _asyncSetPixelStateFn;

        _asyncSetPixelStateFn.initializeNamedFn("setPixelState");
        _asyncSetPixelStateFn.asyncFn();
        _asyncSetPixelStateFn.openBodyFn();
        _asyncSetPixelStateFn.appendFn("const pixelCanvas = state.canvasArea;");
        _asyncSetPixelStateFn.appendFn("const ctx = state.context;");
        _asyncSetPixelStateFn.appendFn(
            _forLoop(
                "idx",
                "state.indexedColors.length",
                "2",
                string.concat(
                    "const colorIndex = parseInt(state.indexedColors[idx], 16);",
                    "const x = idx % 512;",
                    "const y = Math.floor(idx / 512);",
                    "ctx.fillStyle = state.colors[colorIndex];",
                    "ctx.fillRect(x * state.gridSize, y * state.gridSize, 1 * state.gridSize, 1 * state.gridSize);"
                )
            )
        );

        _asyncSetPixelStateFn.closeBodyFn();

        _script.scriptContent = LibString.concat(_script.scriptContent, _asyncSetPixelStateFn.readFn());
    }

    function _getDelta(script memory _script) internal pure {
        fn memory _getDeltaFn;

        _getDeltaFn.initializeNamedFn("getDelta");
        _getDeltaFn.openBodyFn();
        _getDeltaFn.appendFn('console.log("state.changes:", state.changes);');
        _getDeltaFn.closeBodyFn();

        _script.scriptContent = string.concat(
            _script.scriptContent, "mintButton.addEventListener('click', drawGrid());", _getDeltaFn.readFn()
        );
    }

    function _getFunctions(script memory _script) internal pure {
        _asyncSetPixelState(_script);
        _getDelta(_script);
    }

    function _getColorPickerEventListerns(script memory _script) internal pure {
        fn memory _getColorPickerEventListernsFn;

        _getColorPickerEventListernsFn.initializeArgsFn("event");
        _getColorPickerEventListernsFn.openBodyFn();
        _getColorPickerEventListernsFn.appendFn("const selectedColor = event.target.value;");
        _getColorPickerEventListernsFn.appendFn("if (selectedColor) {");
        _getColorPickerEventListernsFn.appendFn("state.activeColor = nearestColor(selectedColor);}");
        _getColorPickerEventListernsFn.closeBodyFn();
        _getColorPickerEventListernsFn.appendFn(");");

        string memory _baseColorPicker = _getColorPickerEventListernsFn.readFn();

        _script.scriptContent = string.concat(
            _script.scriptContent,
            LibString.concat("colorPicker.addEventListener('change', ", _baseColorPicker),
            LibString.concat("colorPicker.addEventListener('input', ", _baseColorPicker)
        );
    }

    function _getMousedown(script memory _script) internal pure {
        fn memory _getMousedownFn;

        _getMousedownFn.initializeArgsFn("event");
        _getMousedownFn.prependFn("pixelArtArea.addEventListener('mousedown', ");
            _getMousedownFn.openBodyFn();
                _getMousedownFn.appendFn("if (event.button == 0) {");
                _getMousedownFn.appendFn("state.isLeftMouseDown = true;");
                _getMousedownFn.appendFn("if (state.currentStep === null || state.isStepComplete) {");
                _getMousedownFn.appendFn("state.currentStep = {changes: [], erasures: []};");
                _getMousedownFn.appendFn("state.isStepComplete = false;}");
                _getMousedownFn.appendFn("handlePixelColor(event);");
                _getMousedownFn.appendFn("} else if (event.button == 2) {");
                _getMousedownFn.appendFn("state.isRightMouseDown = true;");
                _getMousedownFn.appendFn("state.dragStartX = event.clientX;");
                _getMousedownFn.appendFn("state.dragStartY = event.clientY;");
                _getMousedownFn.appendFn("state.dragOffsetX = state.dragStartX - pixelArtArea.offsetLeft;");
                _getMousedownFn.appendFn("state.dragOffsetY = state.dragStartY - pixelArtArea.offsetTop;");
                _getMousedownFn.appendFn("} else if (event.button == 1) {");
                _getMousedownFn.appendFn("state.dragStartX = 0;");
                _getMousedownFn.appendFn("state.dragStartY = 0;");
                _getMousedownFn.appendFn("state.dragOffsetX = 0;");
                _getMousedownFn.appendFn("state.dragOffsetY = 0;");
                _getMousedownFn.appendFn("state.zoomLevel = 1;");
                _getMousedownFn.appendFn("state.cursorSize = 1;");
                _getMousedownFn.appendFn("pixelArtArea.style.transformOrigin = '100}% 100}%';");
                _getMousedownFn.appendFn("pixelArtArea.style.transform = `scale(${ state.zoomLevel })`;}");
            _getMousedownFn.closeBodyFn();
        _getMousedownFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getMousedownFn.readFn());
    }



    function _getMouseUp(script memory _script) internal pure {
        fn memory _getMouseupFn;

        _getMouseupFn.initializeArgsFn("event");
        _getMouseupFn.prependFn("pixelArtArea.addEventListener('mouseup', ");
            _getMouseupFn.openBodyFn();
                _getMouseupFn.appendFn("state.isLeftMouseDown = false;");
                _getMouseupFn.appendFn("state.isRightMouseDown = false;");
                _getMouseupFn.appendFn("if (event.button === 0) {");
                _getMouseupFn.appendFn("state.isStepComplete = true;}");
            _getMouseupFn.closeBodyFn();
        _getMouseupFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getMouseupFn.readFn());
    }

    function _getMousemove(script memory _script) internal pure {

        fn memory _getMousemoveFn;

        _getMousemoveFn.initializeArgsFn("event");
        _getMousemoveFn.prependFn("pixelArtArea.addEventListener('mousemove', ");
            _getMousemoveFn.openBodyFn();
                _getMousemoveFn.appendFn("if (state.isLeftMouseDown) {");
                _getMousemoveFn.appendFn("handlePixelColor(event);");
                _getMousemoveFn.appendFn("} else if (state.isRightMouseDown) {");
                _getMousemoveFn.appendFn("const offsetX = event.clientX - state.dragStartX;");
                _getMousemoveFn.appendFn("const offsetY = event.clientY - state.dragStartY;");
                _getMousemoveFn.appendFn("const scrollX = (state.dragOffsetX - offsetX) / pixelArtArea.offsetWidth;");
                _getMousemoveFn.appendFn("const scrollY = (state.dragOffsetY - offsetY) / pixelArtArea.offsetHeight;");
                _getMousemoveFn.appendFn("pixelArtArea.style.transformOrigin = `${ scrollX * 100}% ${ scrollY * 100}%`;}");
                _getMousemoveFn.appendFn("handleCursorHighlighting(event);");
            _getMousemoveFn.closeBodyFn();
        _getMousemoveFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getMousemoveFn.readFn());
    }

    function _getMouseleave(script memory _script) internal pure {
        fn memory _getMouseleaveFn;

        _getMouseleaveFn.initializeArgsFn("event");
        _getMouseleaveFn.prependFn("pixelArtArea.addEventListener('mouseleave', ");
            _getMouseleaveFn.openBodyFn();
                _getMouseleaveFn.appendFn("state.isLeftMouseDown = false;");
                _getMouseleaveFn.appendFn("state.isRightMouseDown = false;");
            _getMouseleaveFn.closeBodyFn();
        _getMouseleaveFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getMouseleaveFn.readFn());
    }


    function _getWheel(script memory _script) internal pure {
        fn memory _getWheelFn;

        _getWheelFn.initializeArgsFn("event");
        _getWheelFn.prependFn("pixelArtArea.addEventListener('wheel', ");
            _getWheelFn.openBodyFn();
                _getWheelFn.appendFn("const zoomSpeed = 0.1;");
                _getWheelFn.appendFn("if (event.deltaY < 0) {");
                _getWheelFn.appendFn("state.zoomLevel = Math.min(state.zoomLevel + zoomSpeed, 10);");
                _getWheelFn.appendFn("} else {");
                _getWheelFn.appendFn("state.zoomLevel = Math.max(state.zoomLevel - zoomSpeed, 1);");
                _getWheelFn.appendFn("}");
                _getWheelFn.appendFn("const rect = pixelArtArea.getBoundingClientRect();");
                _getWheelFn.appendFn("const cursorX = event.clientX - rect.left;");
                _getWheelFn.appendFn("const cursorY = event.clientY - rect.top;");
                _getWheelFn.appendFn("const scrollX = cursorX / pixelArtArea.offsetWidth;");
                _getWheelFn.appendFn("const scrollY = cursorY / pixelArtArea.offsetHeight;");
                _getWheelFn.appendFn("pixelArtArea.style.transformOrigin = `${ scrollX * 100}% ${ scrollY * 100}%`;");
                _getWheelFn.appendFn("pixelArtArea.style.transform = `scale(${ state.zoomLevel })`;");
                _getWheelFn.appendFn("event.preventDefault();");
            _getWheelFn.closeBodyFn();
        _getWheelFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getWheelFn.readFn());
    }

    function _getMouseEventListerns(script memory _script) internal pure {
        _getMousedown(_script);
        _getMouseUp(_script);
        _getMousemove(_script);
        _getMouseleave(_script);
        _getWheel(_script);

    }

    function _getKeydown(script memory _script) internal pure {
        fn memory _getKeydownFn;

        _getKeydownFn.initializeArgsFn("event");
        _getKeydownFn.prependFn("window.addEventListener('keydown', ");
            _getKeydownFn.openBodyFn();
                _getKeydownFn.appendFn("if (event.key === '+') {");
                _getKeydownFn.appendFn("state.cursorSize = Math.min(state.cursorSize + 1, 32);");
                _getKeydownFn.appendFn("handleCursorHighlighting(event);");
                _getKeydownFn.appendFn("} else if (event.key === '-') {");
                _getKeydownFn.appendFn("state.cursorSize = Math.max(state.cursorSize - 1, 1);");
                _getKeydownFn.appendFn("handleCursorHighlighting(event);}");
            _getKeydownFn.closeBodyFn();
        _getKeydownFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getKeydownFn.readFn());
    }

    function _getEraseBtnListern(script memory _script) internal pure {
        fn memory _getEraseBtnFn;

        _getEraseBtnFn.initializeArgsFn("event");
            _getEraseBtnFn.prependFn("document.getElementById('eraser-btn').addEventListener('click', ");
            _getEraseBtnFn.openBodyFn();
                _getEraseBtnFn.appendFn("if (currentStep !== null && isStepComplete) {");
                _getEraseBtnFn.appendFn("handleEraser();");
                _getEraseBtnFn.appendFn("isStepComplete = false;}");
            _getEraseBtnFn.closeBodyFn();
        _getEraseBtnFn.appendFn(");");

        _script.scriptContent = string.concat(_script.scriptContent, _getEraseBtnFn.readFn());
    }

    function _getEventListerns(script memory _script) internal pure {
        _getColorPickerEventListerns(_script);
        _getMouseEventListerns(_script);
        _getKeydown(_script);
        _getEraseBtnListern(_script);
    }

    function _getHandleCursorHighlighting(script memory _script) internal pure {
        fn memory _getHandleCursorHighlightingFn;

        _getHandleCursorHighlightingFn.initializeNamedArgsFn("handleCursorHighlighting", "event");
        _getHandleCursorHighlightingFn.openBodyFn();
            _getHandleCursorHighlightingFn.appendFn("const rect = pixelArtArea.getBoundingClientRect();");
            _getHandleCursorHighlightingFn.appendFn("const x = event.clientX + window.scrollX - rect.left;");
            _getHandleCursorHighlightingFn.appendFn("const boxSize = state.cursorSize;");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.left = x + 'px';");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.top = event.clientY + 'px';");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.width = boxSize + 'px';");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.height = boxSize + 'px';");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.backgroundColor = state.activeColor;");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.borderColor = state.activeColor;");
            _getHandleCursorHighlightingFn.appendFn("cursorHighlight.style.opacity = 0.5;");
        _getHandleCursorHighlightingFn.closeBodyFn();

        _script.scriptContent = string.concat(_script.scriptContent, _getHandleCursorHighlightingFn.readFn());
    }

    function _getHandlers(script memory _script) internal pure {
        _script.scriptContent = LibString.concat(_script.scriptContent, 'let changes = [];');
        _getHandleCursorHighlighting(_script);
    }

    function _getRandomIntFromInterval(script memory _script) internal pure {
        fn memory _getRandomIntFromIntervalFn;

        _getRandomIntFromIntervalFn.initializeNamedArgsFn("randomIntFromInterval", "min, max");
        _getRandomIntFromIntervalFn.openBodyFn();
            _getRandomIntFromIntervalFn.appendFn("return Math.floor(Math.random() * (max - min + 1) + min);");
        _getRandomIntFromIntervalFn.closeBodyFn();

        _script.scriptContent = string.concat(_script.scriptContent, _getRandomIntFromIntervalFn.readFn());
    }

    function _getSetTestColors(script memory _script) internal pure {
        arrowFn memory _getSetTestColorsFn;

        _getSetTestColorsFn.initializeNamedArrowFn(ArrowFn.Const, "setTestColors");
        _getSetTestColorsFn.openBodyArrowFn();
            _getSetTestColorsFn.appendArrowFn(
                _forLoop(
                    'idx', 
                    '(512*512)', 
                    'state.indexedColors += randomIntFromInterval(0, 215).toString(16).padStart(2, "0");'
                )
            );
        _getSetTestColorsFn.closeBodyArrowFn();

        _script.scriptContent = string.concat(_script.scriptContent, _getSetTestColorsFn.readArrowFn());

    }

    function _getWebsafeColors(script memory _script) internal pure {   

        _script.scriptContent = string.concat(
            _script.scriptContent, 
            string.concat(
                "const colorPalette = '",
                LibString.toHexStringNoPrefix(WebSafeColors.writeColors()), 
                "';"
            ), 
            _forLoop(
                'i', 
                'colorPalette.length',
                '6',
                "state.colors.push('#' + colorPalette.slice(i, i + 6));"
            )
        );

    }

    function _getColorHelpers(script memory _script) internal pure {
        _getRandomIntFromInterval(_script);
        _getSetTestColors(_script);
    }
    

    function _getScripts(bytes memory _pixels) public pure returns (string memory) {
        script memory _script;

        _stateVars(_script);
        _getWebsafeColors(_script);
        _setColors(_script, _pixels);
        _getArrowFns(_script);
        _getFunctions(_script);
        _getEventListerns(_script);
        _getHandlers(_script);
        _getColorHelpers(_script);

        return _script.scriptContent;
    }
}
