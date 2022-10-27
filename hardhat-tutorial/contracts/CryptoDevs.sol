// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";


contract CryptoDevs is ERC721Enumerable, Ownable {


    string _baseTokenUrI;

    uint256 public _price = 0.01 ether;
    bool public _paused;
    uint256 public maxTokenIds = 20;
    uint256 public tokenIds;

    IWhitelist whitelist;

    bool public presalesStarted;
    uint256 public presalesEnded;

    modifier OnlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
            _baseTokenUrI = baseURI;
            whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public OnlyWhenNotPaused {
        presalesStarted = true;


        presalesEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable OnlyWhenNotPaused {
        require(presalesStarted && block.timestamp < presalesEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");

        tokenIds += 1;

        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable OnlyWhenNotPaused {
        require(presalesStarted && block.timestamp >=  presalesEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenUrI;
    }

      function setPaused(bool val) public onlyOwner {
        _paused = val;
    }


    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}


    fallback() external payable {}



}