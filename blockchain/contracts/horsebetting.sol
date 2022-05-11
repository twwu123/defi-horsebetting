// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Horsebetting is Ownable {
    struct Bet {
        address bettor;
        uint8 horseNumber;
        uint256 amount;
    }

    event BetEvent(uint8 _horseNumber, uint256 _betAmount);

    bool _raceComplete = false;
    mapping(address => Bet[]) addressToBets;
    mapping(uint8 => address[]) horseToAddresses;
    mapping(uint8 => uint256) horseToAmount;
    mapping(uint8 => uint256) horseToOdds;

    uint8 winningHorse = -1;

    uint256 public houseLength;
    uint256 public taxRate;

    constructor(uint256 _houseLength, uint256 _taxRate) {
        houseLength = _houseLength;
        taxRate = _taxRate;
    }

    function bet(uint8 _horseNumber, uint256 _amount) external payable {
        require(msg.value >= _amount, "#BET: WRONG_BET_FEE");
        require(payable(msg.sender).send(msg.value), "BET: FEE_NOT_ENOUGH");
        totalPoolAmount += _amount;
        horseToAmount[_horseNumber] += _amount;

        Bet memory _bet = Bet(payable(msg.sender), _horseNumber, _amount);
        addressToBets[msg.sender].push(_bet);

        bool alreadyBetHorse = false;
        for (uint256 i = 0; i < horseToAddresses[_horseNumber].length; i++) {
            if (horseToAddresses[_horseNumber][i] == msg.sender) {
                alreadyBetHorse = true;
            }
        }
        if (!alreadyBetHorse) {
            horseToAddresses[_horseNumber].push(payable(msg.sender));
        }

        emit BetEvent(_horseNumber, _amount);
    }

    function distributeWinnings(uint8 _winningHorse)
        external
        payable
        onlyOwner
    {
        // calculate total reward first
        uint256 totalReward = address(this).balance -
            ((address(this).balance * taxRate) / 100);

        // calculate oddds
        uint256 odds = horseToAmount[_winningHorse] / totalReward;

        // Get winner number
        uint256 winnerNumber = horseToAddresses[_winningHorse].length;
        address[] winningBettors = horseToAddresses[_winningHorse];

        for (uint256 i = 0; i < winnerNumber; i++) {
            uint256 winnerBetAmount = _calculateWinningBetAmount(
                _winningHorse,
                winningBettors[i]
            );

            uint256 winnerReward = winnerBetAmount * odds;
            (bool sent, bytes memory data) = winningBettors[i].call{
                value: winnerReward
            }("");
            require(sent, "Failed to send Ether to user");
        }
    }

    function _calculateWinningBetAmount(uint8 _winningHorse, address _bettor)
        private
        view
        returns (uint256)
    {
        Bet[] memory winningBets = addressToBets[_bettor];
        uint256 betAmount = 0;
        for (uint256 i = 0; i < winningBets.length; i++) {
            if (winningBets[i].horseNumber == _winningHorse) {
                betAmount += winningBets[i].amount;
            }
        }
        return betAmount;
    }
}
