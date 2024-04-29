// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Paper is ERC721, Ownable(msg.sender) {
    uint256 public constant MAX_TOKENS = 1;
    uint256 private totalTokensMinted;

    constructor() ERC721("MyPaperCollection", "PAPERS") {}

    function transferTokenPaper(address _to) external onlyOwner{
        require(balanceOf(_to) < MAX_TOKENS, "Recipient already has a token");
        _mint(_to, totalTokensMinted);
        totalTokensMinted++;
    }
}
