// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RockPaperScissors is ERC721, Ownable {
    enum Move { None, Rock, Paper, Scissors }

    struct Game {
        address player;
        Move playerMove;
        Move contractMove;
        bool played;
    }

    mapping(uint256 => Game) private games;
    uint256 public gameId = 0;

    event GamePlayed(address player, uint256 gameId, Move playerMove, Move contractMove, address winner, string result);

    constructor() ERC721("RockPaperScissorsToken", "RPS") Ownable(msg.sender) {}

    function play(uint256 _move) external {
        require(_move >= 1 && _move <= 3, "Invalid move");
        require(balanceOf(msg.sender) == 0, "You already played a game");

        Move playerMove = Move(_move);
        Move contractMove = Move(random());
        address winner = determineWinner(playerMove, contractMove);
        string memory result;

        if (winner == msg.sender) {
            _safeMint(msg.sender, gameId);
            result = "You win!";
        } else if (winner == address(0)) {
            result = "It's a tie!";
        } else {
            result = "You lose!";
        }

        games[gameId] = Game(msg.sender, playerMove, contractMove, true);
        emit GamePlayed(msg.sender, gameId, playerMove, contractMove, winner, result);

        gameId++;
    }

    function determineWinner(Move _playerMove, Move _contractMove) internal view returns (address) {
        if (_playerMove == _contractMove) {
            return address(0); // Tie
        } else if ((_playerMove == Move.Rock && _contractMove == Move.Scissors) ||
                   (_playerMove == Move.Paper && _contractMove == Move.Rock) ||
                   (_playerMove == Move.Scissors && _contractMove == Move.Paper)) {
            return msg.sender; // Player wins
        } else {
            return address(this); // Contract wins
        }
    }

    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 3 + 1;
    }
}
