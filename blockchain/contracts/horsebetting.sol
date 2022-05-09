// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Horsebetting is Ownable {
    struct Bet {
        address bettor;
        uint8 horseNumber;
        uint256 amount;
    }

    bool _raceComplete = false;
    mapping(address => Bet[]) addressToBets;
    mapping(uint8 => address[]) horseToAddresses;

    function bet(uint8 _horseNumber, uint256 _amount) external payable {
        require(msg.value >= _amount);
        require(payable(msg.sender).send(msg.value));
        Bet memory _bet = Bet(payable(msg.sender), _horseNumber, _amount);

        addressToBets[payable(msg.sender)].push(_bet);
        horseToAddresses[_horseNumber].push(payable(msg.sender));
    }

    // function distributeWinnings(uint8 _winningHorse) external onlyOwner {
    //     uint256 betTotal = address(this).balance;
    //     uint256 winningHorseBetTotalAmount = 0;
    //     mapping(address => uint256) addressToBetAmount;

    //     address[] winningBettors = horseToAddresses[_winningHorse];
    // }

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
