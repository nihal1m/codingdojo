import Web3 from "web3";
import metaCoinArtifact from "../../build/contracts/donationT.json";

const App = {
 web3: null,
 account: null,
 meta: null,

 start: async function() {
   const { web3 } = this;

   try {
     // get contract instance
     const networkId = await web3.eth.net.getId();
     const deployedNetwork = metaCoinArtifact.networks[networkId];
     this.meta = new web3.eth.Contract(
       metaCoinArtifact.abi,
       deployedNetwork.address,
     );

     // get accounts
     const accounts = await web3.eth.getAccounts();
     this.account = accounts[0];
     //console.log()

     this.refreshBalance();
   } catch (error) {
     console.error("Could not connect to contract or chain.");
   }
 },
 registerOrganization: async function() {
   const { registerOrganization } = this.meta.methods;
   const orgname = document.getElementById("orgName").value;
   const orgtype = document.getElementById("orgType").value;

   await registerOrganization(orgname, orgtype).send({ from: this.account }).then(function(res){
     console.log(res)
   });
;

 },

verifyOrg: async function() {
 const { verifyOrganization } = this.meta.methods;
 const orgID = parseInt(document.getElementById("orgID").value);
 await verifyOrganization(orgID).send({ from: this.account }).then(function(res){
   console.log(res);
 });
},

createCamp: async function() {
 const { createCampaign } = this.meta.methods;
 const campname = document.getElementById("campName").value;
 const camptype = document.getElementById("campType").value;
 //const camptarget = parseInt(document.getElementById("CampTarget").value);
 const campstart = document.getElementById("campName").value;
 const campend = document.getElementById("campName").value;
 const campexec = 1;//parseInt(document.getElementById("Exec").value);
 await createCampaign(campname, camptype, 10, 1618807133, 1680513491, campexec).send({ from: this.account }).then(function(res){
   console.log(res);
 });

},
setExecutor: async function() {
 const { setExecutors } = this.meta.methods;
 const name = document.getElementById("ExeName").value;
 const category = document.getElementById("ExecType").value;
 const address = document.getElementById("ExecAddress").value;
 await setExecutors(1,  name, category, address).send({ from: this.account }).then(function(res){
   console.log(res);
 });
},

sendDonation: async function() {
  const { donate } = this.meta.methods;
  const campID = 1 ;//parseInt(document.getElementById("campID1").value);
  const Amount = 100; //parseInt(document.getElementById("amount").value);
  await donate(campID, Amount).send({ from: this.account }).then(function(res){
    console.log(res);
  });
}
,

 refreshBalance: async function() {
   const { getBalance } = this.meta.methods;
   const balance = await getBalance(this.account).call();

   const balanceElement = document.getElementsByClassName("balance")[0];
   balanceElement.innerHTML = balance;
 },

 sendCoin: async function() {
   const amount = parseInt(document.getElementById("amount").value);
   const receiver = document.getElementById("receiver").value;

   this.setStatus("Initiating transaction... (please wait)");

   const { sendCoin } = this.meta.methods;
   await sendCoin(receiver, amount).send({ from: this.account });

   this.setStatus("Transaction complete!");
   this.refreshBalance();
 },

 setStatus: function(message) {
   const status = document.getElementById("status");
   status.innerHTML = message;
 },
};

window.App = App;

window.addEventListener("load", function() {
 if (window.ethereum) {
   // use MetaMask's provider
   App.web3 = new Web3(window.ethereum);
   window.ethereum.enable(); // get permission to access accounts
 } else {
   console.warn(
     //"No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live",
   );
   // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
   App.web3 = new Web3(
     new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
   );
 }

 App.start();

 $(document).ready(function () {
  //@naresh action dynamic childs
  var next = 0;
  $("#add-more").click(function(e){
      e.preventDefault();
      var addto = "#field" + next;
      var addRemove = "#field" + (next);
      next = next + 1;
      var newIn = ' <div id="field'+ next +'" name="field'+ next +'"><!-- Text input--><div class="form-group"> <label class="col-md-4 control-label" for="action_id">Action Id</label> <div class="col-md-5"> <input id="action_id" name="action_id" type="text" placeholder="" class="form-control input-md"> </div></div><br><br> <!-- Text input--><div class="form-group"> <label class="col-md-4 control-label" for="action_name">Action Name</label> <div class="col-md-5"> <input id="action_name" name="action_name" type="text" placeholder="" class="form-control input-md"> </div></div><br><br><!-- File Button --> <div class="form-group"> <label class="col-md-4 control-label" for="action_json">Action JSON File</label> <div class="col-md-4"> <input id="action_json" name="action_json" class="input-file" type="file"> </div></div></div>';
      var newInput = $(newIn);
      var removeBtn = '<button id="remove' + (next - 1) + '" class="btn btn-danger remove-me" >Remove</button></div></div><div id="field">';
      var removeButton = $(removeBtn);
      $(addto).after(newInput);
      $(addRemove).after(removeButton);
      $("#field" + next).attr('data-source',$(addto).attr('data-source'));
      $("#count").val(next);  
      
          $('.remove-me').click(function(e){
              e.preventDefault();
              var fieldNum = this.id.charAt(this.id.length-1);
              var fieldID = "#field" + fieldNum;
              $(this).remove();
              $(fieldID).remove();
          });
  });

});

});




   
              
      
  



