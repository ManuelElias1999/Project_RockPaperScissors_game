// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Rock.sol";
import "./Paper.sol";
import "./Scissor.sol";

contract RockPaperScissors {
    enum Move { None, Rock, Paper, Scissors }

    struct Game {
        address player1;
        address player2;
        Move player1Move;
        Move player2Move;
        bool played;
        bool player1Ready;
        bool player2Ready;
    }

    mapping(uint256 => Game) private games;
    uint256 public gameId = 1;

    uint randNo = 0;

    uint randomMachine = 0;

    Rock public rockToken;
    Paper public paperToken;
    Scissor public scissorToken;

    event GameCreated(uint256 gameId, address player1);
    event GameJoined(uint256 gameId, address player2);
    event GamePlayed(uint256 gameId, address player, Move move);
    event GameFinished(uint256 gameId, address winner, string result);

    constructor(address _rockAddress, address _paperAddress, address _scissorAddress) {
        rockToken = Rock(_rockAddress);
        paperToken = Paper(_paperAddress);
        scissorToken = Scissor(_scissorAddress);
    }

    // Create a new game
    function createGame() external returns (uint) {
        games[gameId].player1 = msg.sender;

        emit GameCreated(gameId, msg.sender);

        return gameId++;
    }

    // Join an existing game
    function joinGame(uint256 _gameId) external {
        require(games[_gameId].player1 != address(0), "Game does not exist");
        require(games[_gameId].player2 == address(0), "Game already has two players");
        require(games[_gameId].player1 != msg.sender, "You cannot join your own game");

        games[_gameId].player2 = msg.sender;

        emit GameJoined(_gameId, msg.sender);
    }

    // Play the game
    function playGame(uint256 _move) external {
        require(games[gameId - 1].player1 != address(0), "Game does not exist");
        require(games[gameId - 1].played == false, "Game has already been played");
        require(_move >= 1 && _move <= 3, "Invalid move");
        require(msg.sender == games[gameId - 1].player1 || msg.sender == games[gameId - 1].player2, "You are not allowed to play this game");

        if (msg.sender == games[gameId - 1].player1) {
            require(games[gameId - 1].player1Move == Move.None, "You have already selected a move");
            if (_move == 1) {
                require(rockToken.balanceOf(msg.sender) > 0, "You don't have the Rock token");
            } else if (_move == 2) {
                require(paperToken.balanceOf(msg.sender) > 0, "You don't have the Paper token");
            } else if (_move == 3) {
                require(scissorToken.balanceOf(msg.sender) > 0, "You don't have the Scissor token");
            }
            games[gameId - 1].player1Move = Move(_move);
        } else {
            require(games[gameId - 1].player2Move == Move.None, "You have already selected a move");
            if (_move == 1) {
                require(rockToken.balanceOf(msg.sender) > 0, "You don't have the Rock token");
            } else if (_move == 2) {
                require(paperToken.balanceOf(msg.sender) > 0, "You don't have the Paper token");
            } else if (_move == 3) {
                require(scissorToken.balanceOf(msg.sender) > 0, "You don't have the Scissor token");
            }
            games[gameId - 1].player2Move = Move(_move);
        }

        emit GamePlayed(gameId - 1, msg.sender, Move(_move));

        if (games[gameId - 1].player1Move != Move.None && games[gameId - 1].player2Move != Move.None) {
            address winner;
            string memory result;
            if (games[gameId - 1].player1Move == games[gameId - 1].player2Move) {
                winner = address(0); // Tie
                result = "It's a tie!";
            } else if (
                (games[gameId - 1].player1Move == Move.Rock && games[gameId - 1].player2Move == Move.Scissors) ||
                (games[gameId - 1].player1Move == Move.Paper && games[gameId - 1].player2Move == Move.Rock) ||
                (games[gameId - 1].player1Move == Move.Scissors && games[gameId - 1].player2Move == Move.Paper)
            ) {
                winner = games[gameId - 1].player1; // Player 1 wins
                result = "Player 1 wins!";
            } else {
                winner = games[gameId - 1].player2; // Player 2 wins
                result = "Player 2 wins!";
            }

            emit GameFinished(gameId - 1, winner, result);

            games[gameId - 1].played = true;
        }
    }

    // Play against the machine
    function playAgainstMachine(uint256 _move) external {
        require(randomMachine == 0, "Click on play again");
        require(_move >= 1 && _move <= 3, "Invalid move");

        if (_move == 1) {
            require(rockToken.balanceOf(msg.sender) > 0, "You don't have the Rock token");
        } else if (_move == 2) {
            require(paperToken.balanceOf(msg.sender) > 0, "You don't have the Paper token");
        } else if (_move == 3) {
            require(scissorToken.balanceOf(msg.sender) > 0, "You don't have the Scissor token");
        }

        Move playerMove = Move(_move);
        Move machineMove = Move(random());

        emit GamePlayed(0, msg.sender, playerMove);
        emit GamePlayed(0, address(this), machineMove);

        address winner;
        string memory result;
        if (playerMove == machineMove) {
            winner = address(0); // Tie
            result = "It's a tie!";
        } else if (
            (playerMove == Move.Rock && machineMove == Move.Scissors) ||
            (playerMove == Move.Paper && machineMove == Move.Rock) ||
            (playerMove == Move.Scissors && machineMove == Move.Paper)
        ) {
            winner = msg.sender; // Player wins
            result = "You win!";
        } else {
            winner = address(this); // Machine wins
            result = "You lose!";
        }

        emit GameFinished(0, winner, result);
    }

    // Generate a random number
    function random() internal returns (uint256) {
        randomMachine = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 3 + 1;
        return randomMachine;
    }

    function playAgainMachine() external {
        randomMachine = 0;
    }

    // Play again in the same game
    function playAgainPlayers() external {
        require(games[gameId - 1].played == true, "Game is still in progress");
        require(msg.sender == games[gameId - 1].player1 || msg.sender == games[gameId - 1].player2, "You are not part of this game");

        // Mark both players ready for the new game
        if (msg.sender == games[gameId - 1].player1) {
            games[gameId - 1].player1Ready = true;
        } else {
            games[gameId - 1].player2Ready = true;
        }

        // Check if both players are ready to start the new game
        if (games[gameId - 1].player1Ready && games[gameId - 1].player2Ready) {
            // Reset game state
            games[gameId - 1].player1Move = Move.None;
            games[gameId - 1].player2Move = Move.None;
            games[gameId - 1].played = false;
            games[gameId - 1].player1Ready = false;
            games[gameId - 1].player2Ready = false;

            emit GameCreated(gameId, msg.sender);
        }
    }
}
