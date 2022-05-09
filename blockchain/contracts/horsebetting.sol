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
}
