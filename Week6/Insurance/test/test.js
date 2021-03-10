const Insurance = artifacts.require("Insurance");



contract("Insurance", async function(accounts){

    it(
        "should add Product", async function(){
            let instance = await Insurance.deployed()
            await instance.addProduct(1, "Tv",10 , {from: accounts[2]});
    });

 



});