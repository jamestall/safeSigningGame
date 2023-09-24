// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SigningGame {
    uint256 public constant JOIN_AMOUNT = 1000 wei;
    uint256 public constant GAME_CONTRIBUTION = 100 wei;

    address[4] public players;
    uint256 public currentPlayers = 0;
    mapping(address => uint256) public balances;

    bool public gameStarted = false;
    uint256 public prizePool = 0;
    uint256 public signedPlayersCount = 0;
    address[2] public winners;

    event Joined(address player);
    event GameStarted();
    event GameEnded(address[2] winners, uint256[2] amounts);

    function join() external payable {
        require(!gameStarted, "Game is already started");
        require(currentPlayers < 4, "All player slots are occupied");
        require(msg.value == JOIN_AMOUNT, "You must send exactly 1000 wei to join");
        
        players[currentPlayers] = msg.sender;
        balances[msg.sender] = JOIN_AMOUNT;
        currentPlayers++;

        emit Joined(msg.sender);

        if (currentPlayers == 4) {
            gameStarted = true;
            for (uint i = 0; i < 4; i++) {
                balances[players[i]] -= GAME_CONTRIBUTION;
                prizePool += GAME_CONTRIBUTION;
            }
            emit GameStarted();
        }
    }

    function sign() external {
        require(gameStarted, "Game hasn't started yet");
        require(balances[msg.sender] >= GAME_CONTRIBUTION, "Not enough balance to sign");
        require(signedPlayersCount < 2, "Two players have already signed");
        for(uint i = 0; i < signedPlayersCount; i++) {
            require(winners[i] != msg.sender, "You have already signed");
        }

        winners[signedPlayersCount] = msg.sender;
        signedPlayersCount++;

        if (signedPlayersCount == 2) {
            distributePrizes();
        }
    }

    function distributePrizes() private {
        uint256[2] memory distributions = [
            (prizePool * 60) / 100,
            (prizePool * 40) / 100
        ];

        for (uint256 i = 0; i < 2; i++) {
            balances[winners[i]] += distributions[i];
        }

        emit GameEnded(winners, distributions);

        // Reset the game state
        delete players;
        currentPlayers = 0;
        gameStarted = false;
        prizePool = 0;
        signedPlayersCount = 0;
        delete winners;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getPlayerDetails() external view returns (address[4] memory, uint256[4] memory) {
    uint256[4] memory playerBalances;

    for (uint i = 0; i < 4; i++) {
        playerBalances[i] = balances[players[i]];
    }

    return (players, playerBalances);
}

}
