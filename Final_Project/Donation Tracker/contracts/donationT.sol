pragma solidity ^0.8.0;


import "./ERC20.sol";


contract donationT is ERC20{


	address Owner;
    
	constructor() public {
    	Owner = msg.sender;
	}
	modifier onlyAdmin {
    	require(msg.sender == Owner, "You do not have adminstrive permission");
    	_;
	}
    
	modifier authorized(uint id){
    	require(msg.sender == ownerOf(id), "you are not authorized to update this camp");
    	_;
	}
    
	modifier mycamp(uint ID){
    	require(Campaigns[ID].byOrgID == Organizations[msg.sender].orgID, "You are not authorized to edit this campaign");
    	_;
	}
    
	modifier registered{
    	require(Organizations[msg.sender].orgID != 0, "You are not authorized");
    	_;
	}
    
   	 
	modifier relasechk(uint campID){
    	require(Campaigns[campID].byOrgID == Organizations[msg.sender].orgID ||
    	Executors[campID][1].executorAddress == msg.sender, "Your are not Autorized!");
    	_;   	 
	}
    
	struct registerOrg{
    	uint regOrgID;
    	string orgName;
    	string orgCategory;
    	address orgAddress;
    	verification verify;
    	uint time;
	}
    
	uint regCounter;
	uint waitingOrg;
	enum verification{rejected, waiting, accepted}
	mapping(uint => registerOrg) orgRegister;
	mapping(address => verification) orgRegState;
    
	struct Organization{
    	uint orgID;
    	string orgName;
    	string orgCategory;
    	address orgAddress;
    	uint totalCamps;
    	uint openCamps;
    	uint verficationTime;
	}
    
	uint orgCounter;
	mapping(address => Organization) Organizations;

	struct Campaign{
    	uint byOrgID;
    	uint campID;
    	string campName;
    	string campCategory;
    	uint fundTarget;
    	uint startDate;
    	uint endDate;
    	campaignStatus status;
    	uint donations;
    	uint creationTime;
    	uint executorNumbers;
	}
    
	uint campCounter;
	enum campaignStatus{Open, Closed}
	mapping(uint => Campaign) Campaigns;
    
    
	struct Executor{
    	uint campID;
    	uint executorID;
    	string executorName;
    	string executorCategory;
    	address executorAddress;
	}
    
	uint exeCounter;

	mapping(uint=> mapping(uint=>Executor)) Executors;

	mapping(address => mapping(uint =>uint)) ExeID;

	mapping(uint => uint) ExecutorCount;
    
    
	struct CampOperation{
    	uint campID;
    	uint ExecutorID;
    	campPhase phase;
    	campStatus status;
    	uint lastUpdate;
    	string feedback;
	}
    

	enum campPhase {Fundrasing, Preparing, Shipping, Distributing, End, _undefined}
	enum campStatus{Received, in_Progress, Completed}
    
	mapping(uint => mapping(uint => CampOperation)) campOperations;
    
	struct Donation{
    	uint campID;
    	uint donID;
    	uint amount;
    	uint time;
	}
    
	uint donCounter;
	mapping(address => Donation) Donations;
	mapping(address => uint[]) mydons;
    
    
	function registerOrganization(string memory orgName, string memory orgCategory) public{
    	require(Organizations[msg.sender].orgID == 0 , "This organization is registered" );
    	require(orgRegState[msg.sender] != verification.waiting, "Your organization account is on waiting list");
    	regCounter++;
    	orgRegister[regCounter] = registerOrg(regCounter, orgName, orgCategory, msg.sender, verification.waiting, block.timestamp);
    	orgRegState[msg.sender]= verification.waiting;
    	waitingOrg++;
    	emit _regiterOrganization(regCounter,  orgName, block.timestamp);
	}
	event _regiterOrganization(uint _ID, string Name, uint indexed time);
    
    
    
	function verifyOrganization(uint _ID) public onlyAdmin{// Owner or Admin// admin
    	require(waitingOrg > 0, "There is no Organization need to be verified");
    	require(orgRegister[_ID].regOrgID != 0, "error");
    	orgCounter++;
   	 
    	Organizations[orgRegister[_ID].orgAddress] = Organization(orgCounter, orgRegister[_ID].orgName, orgRegister[_ID].orgCategory,
    	orgRegister[_ID].orgAddress, 0, 0,  block.timestamp);
   	 
    	emit _verifyOrganization(orgRegister[_ID].orgName, orgRegister[_ID].orgCategory, block.timestamp);
	}
	event _verifyOrganization(string  orgName, string  orgCategory, uint verificationTime);
    
	function createCampaign(string memory campName, string memory campCategory, uint fundTarget, uint startDate, uint endDate, uint ExecNumbers) public registered { // only verfied Orgs
   	 
    	campCounter ++;
    	campaignStatus status = campaignStatus.Closed;
    	if (block.timestamp >= startDate) { status = campaignStatus.Open;}
    	Campaigns[campCounter]= Campaign(Organizations[msg.sender].orgID, campCounter, campName, campCategory, fundTarget, startDate, endDate, status, 0, block.timestamp, ExecNumbers);
    	Organizations[msg.sender].totalCamps ++;
    	if (status == campaignStatus.Open) {Organizations[msg.sender].openCamps ++;}
   	 
    	emit allCampaigns(Organizations[msg.sender].orgID, campCounter, campName, campCategory, fundTarget, startDate, endDate, status, block.timestamp);
	}
	event allCampaigns(uint byOrg, uint campID, string campName, string campCategory, uint fundTarget, uint startDate, uint endDate, campaignStatus status, uint time);
 
       	 
	function setExecutors(uint campID, string memory executName, string memory executCategory, address executAddress) public mycamp(campID){ //verifyOrg(campId =  address)
    	require(ExecutorCount[campID]< Campaigns[campID].executorNumbers, "Not Allowd");
    	ExecutorCount[campID] ++;
    	Executors[campID][ExecutorCount[campID]] = Executor(Campaigns[campID].byOrgID, exeCounter++, executName, executCategory, executAddress);
    	ExeID[executAddress][campID]=exeCounter;
   	 
    	emit _campExecutor(campID, executName, executCategory, executAddress);
	}
	event _campExecutor(uint campID, string executName, string executCategory, address executAddress);
 
	function updateCampOperation(uint campID, campPhase phase, campStatus status, string memory feedback) public authorized(campID){ // only Owner(campID, ExecID)

    	uint executID = ExeID[msg.sender][campID];
    	campOperations[campID][executID] = CampOperation(campID,executID, campPhase(phase), campStatus(status), block.timestamp, feedback);
   	 
    	if (campStatus(status) == campStatus.Completed && executID < Campaigns[campID].executorNumbers){
        	emit _updateCampOperation( campID,  executID,  phase,  status, feedback );
        	executID++;
        	address ExecAdd = Executors[campID][executID].executorAddress;
        	phase = campPhase._undefined;
        	status = campStatus.Received;
        	feedback = "";
        	ERC721_transfer(ownerOf(campID),ExecAdd, campID);

    	} else if (campStatus(status) == campStatus.Completed && executID == Campaigns[campID].executorNumbers){ // the last????
        	phase = campPhase.End; // change ownership
        	ERC721_transfer(ownerOf(campID),address(this), campID);
    	}
   	 
    	emit _updateCampOperation( campID,  executID,  phase,  status, feedback );
	}
  event _updateCampOperation(uint campID, uint executID, campPhase phase, campStatus status, string  feedback );
    
	function exchange(uint amount)public returns(uint){
   	 
    	uint exchangeValue = 1;
    	uint result = (amount / exchangeValue);
   	 
    	return result;
   	 
	}
    
	function donate(uint campID, uint amount) public {
    	require (Campaigns[campID].campID != 0, "This campaign is not exist!");
    	require (Campaigns[campID].status != campaignStatus.Closed, "Donation for this campaign is closed");
    	uint Amount = exchange(amount);

    	ERC20._mint(address(this), Amount);
    	ERC20._balances[address(this)] +=  Amount;
    	Campaigns[campID].donations += Amount;
   	 
   	if( Campaigns[campID].donations >= Campaigns[campID].fundTarget){
       	Campaigns[campID].status = campaignStatus.Closed;
   	}
  	 
    	donCounter++;

    	Donations[msg.sender] = Donation(campID, donCounter, Amount, block.timestamp) ;
    	emit _donation (msg.sender, campID, Amount, block.timestamp);
    	 
	}
    
	event _donation( address doner, uint campID, uint amount, uint time);


	function relaseDoantion(uint campID) public relasechk(campID){ //

    	require(campID != 0 && Campaigns[campID].campID !=0, "Error");
    	require (block.timestamp >= Campaigns[campID].endDate, "you cant");
    	require(campOperations[campID][1].status != campStatus.Completed, "it is released");

    	address ExecAdd = Executors[campID][1].executorAddress;
    	uint amount = Campaigns[campID].donations;
    	ERC721_mint(ExecAdd, campID);
    	withdraw(ExecAdd,amount); // here the donation is relased to the manufacturer
    	campOperations[campID][1].status = campStatus.Completed;
     	emit _relaseDonation(address(this), ExecAdd, amount, campID, Campaigns[campID].byOrgID, 1);
	}
    
    	event _relaseDonation(address conAddrs, address ExecAddrs, uint amount, uint campID, uint orgID, uint ExecID);
   	 
     	function withdraw(address _addrs, uint withdrawAmount) private  returns (uint remainingBal){
        	 
             	require(balanceOf(address(this)) >= withdrawAmount);
            	ERC20._burn(address(this), withdrawAmount);
           	 
            	require(withdrawAmount <= ERC20._balances[address(this)]);
           	 
            	ERC20._transfer(address(this), _addrs,withdrawAmount);
   	 
    	return ERC20._balances[_addrs];
	}
    
    
//------------------------------------------------
//* ERC721
 	 

	event ERC721_Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

	/**
 	* @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
 	*/
	event _Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

	// Mapping from token ID to owner address
	mapping (uint256 => address) private ERC721_owners;

	// Mapping owner address to token count
	mapping (address => uint256) private ERC721_balances;
	// Mapping from token ID to approved address
	mapping (uint256 => address) private ERC721_tokenApprovals;

	function ERC721_beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

	function ERC721_approve(address to, uint256 tokenId) internal virtual {
    	ERC721_tokenApprovals[tokenId] = to;
    	emit Approval(ownerOf(tokenId), to, tokenId);
	}
    
    	function ownerOf(uint256 tokenId) public view virtual  returns (address) {
    	address owner = ERC721_owners[tokenId];
    	require(owner != address(0), "ERC721: owner query for nonexistent token");
    	return owner;
	}
    
	function ERC721_transfer(address from, address to, uint256 tokenId) internal virtual {
    	require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
    	require(to != address(0), "ERC721: transfer to the zero address");

    	ERC721_beforeTokenTransfer(from, to, tokenId);

    	// Clear approvals from the previous owner
    	ERC721_approve(address(0), tokenId);

    	ERC721_balances[from] -= 1;
    	ERC721_balances[to] += 1;
    	ERC721_owners[tokenId] = to;

    	emit ERC721_Transfer(from, to, tokenId);
	}
    
    	function ERC721_mint(address to, uint256 tokenId) internal virtual {
    	require(to != address(0), "ERC721: mint to the zero address");
    	require(!ERC721_exists(tokenId), "ERC721: token already minted");

    	ERC721_beforeTokenTransfer(address(0), to, tokenId);

    	ERC721_balances[to] += 1;
    	ERC721_owners[tokenId] = to;

    	emit ERC721_Transfer(address(0), to, tokenId);
	}
    
    	function ERC721_exists(uint256 tokenId) internal view virtual returns (bool) {
    	return ERC721_owners[tokenId] != address(0);
	}
//** END

}







