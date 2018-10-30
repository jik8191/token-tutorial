var MintedCrowdsale = artifacts.require("MintedCrowdsale");

module.exports = function(deployer) {
    deployer.deploy(MintedCrowdsale(1, "0x37ca96ff49d14db1ca542beaed9042f61610bb00", "0x108ff8cffd20adf3f162653baa85bdc4bbaac60a"));
};

