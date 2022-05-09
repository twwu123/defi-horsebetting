const { expect } = require('chai');
const { ethers } = require('hardhat');

describe("Horsebetting contract", function () {
    let horseBetting;
    beforeEach(async function () {
        const horseBettingContract = await ethers.getContractFactory("Horsebetting");
        horseBetting = await horseBettingContract.deploy();
    })
});