const donationT = artifacts.require("donationT");

contract("donationT", async function(accounts){

    it (
    "should add Organization", async function(){
    let instance = await donationT.deployed()
    await instance.registerOrganization( "ong", "u");
    });

     it('should execute only by the owner', async()=>{
        let instance = await donationT.deployed()
        await instance.verifyOrganization(1);
        await instance.getPastEvents("allEvents", function(error, events){ console.log(events[0].returnValues.orgName, events[0].returnValues.orgCategory, events[0].returnValues.verificationTime);})

      });

    });;
