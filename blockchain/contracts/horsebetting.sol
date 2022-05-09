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
}
