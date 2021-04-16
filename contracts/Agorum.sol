pragma solidity ^0.5.1;

contract Agorum {
	// State variables
	address private adminAccount = 0xa5ebd5E07021F7523E74F46221012CDA18EDf1e4;
	string public name = "Agorum";
	string public symbol = "AGRA";
	string public standard = "Agorum v1.0.0";
	uint256 public totalSupply;
	uint256 public totalUpvotes;
	uint256 public totalPosts;
	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;
	mapping(address => mapping(string => uint[])) public stakes;

	event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 _value
	);

	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
	);

	// transfer

	// allowance

	constructor(uint256 _initialSupply) public {
		totalSupply = _initialSupply;

		// allocate initial supply
		balanceOf[msg.sender] = _initialSupply;
	}

	// Transfer
	function transfer(address _to, uint256 _value) public returns (bool success) {
		// Exception if account doesn't have enough
		require(balanceOf[msg.sender] >= _value);
		// Transfer the balance
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		// Transfer Event
		emit Transfer(msg.sender, _to, _value);
		// Return a boolean
		return true;
	}

	// Approve
	function approve(address _spender, uint256 _value) public returns (bool success) {
		// Require approver to have sufficient tokens
		require(balanceOf[msg.sender] >= _value);
		// allowance
		allowance[msg.sender][_spender] = _value;

		// Approve event
		emit Approval(msg.sender, _spender, _value);

		return true;
	}

	// transferFrom
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {	
		// Require _from has enough tokens
		require(balanceOf[_from] >= _value);

		// Require allowance is big enough
		require(allowance[_from][msg.sender] >= _value);

		// Change the balance
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		// Update the allowance
		allowance[_from][msg.sender] -= _value;

		// Transfer event
		emit Transfer(_from, _to, _value);

		// return a boolean
		return true;
	}

	// stake
	function stake(uint256 _value, string memory _postTitle, uint256 _upvotes, uint256 _comments) public returns (bool success) {
		// Require msg.sender has enought tokens
		require(balanceOf[msg.sender] >= _value);

		// Define uint array of stats
		uint[4] memory postStats = [_value, _upvotes, _comments, now];

		// Change balances, stores stake with admin account
		balanceOf[msg.sender] -= _value;
		balanceOf[adminAccount] += _value; 
		stakes[msg.sender][_postTitle] = postStats;

		// Emit transfer event
		emit Transfer(msg.sender, adminAccount, _value);

		// increase totalPosts count
		// increase totalUpvotes count
		totalPosts += 1;
		totalUpvotes += 1;

		// return a boolean
		return true;
	}

	function upvote(address _poster, string memory _postTitle) public returns (bool success) {
		// increase upvote count in stakes by 1
		stakes[_poster][_postTitle][1] += 1;

		// increase totalUpvotes count by 1
		totalUpvotes += 1;

		// return a boolean
		return true;
	}

	function comment(address _poster, string memory _postTitle) public returns (bool success) {
		// increase comment count in stakes by 1
		stakes[_poster][_postTitle][2] += 1;

		// return a boolean
		return true;
	}

	function updateStake(address _poster, string memory _postTitle) public returns (bool success) {
		uint256 aveUpvotes = totalUpvotes / totalPosts;
		// require upvote count to be greater than average
		require(stakes[_poster][_postTitle][1] >= aveUpvotes);

		// set stake based on upvotes and comments
		stakes[_poster][_postTitle][0] = 1 + (3 * uint256(stakes[_poster][_postTitle][1]) + 1 * uint256(stakes[_poster][_postTitle][2])) / 4;

		// return a boolean
		return true;
	}

	function loseStake(address _poster, string memory _postTitle) public returns (bool success) {
		uint256 aveUpvotes = totalUpvotes / totalPosts;

		// require upvote count to be less than average
		require(stakes[_poster][_postTitle][1] < aveUpvotes);

		// require one day to have past since post created
		uint postDate = stakes[_poster][_postTitle][3];
		uint currDate = now;
		uint diff = (currDate - postDate) / 60 / 60 / 24;

		require(diff >= 1);

		// set stake to 0
		stakes[_poster][_postTitle][0] = 0;

		// return a boolean
		return true;
	}
}