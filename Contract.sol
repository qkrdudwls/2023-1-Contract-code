// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract AJOUTest {
    string public constant name = "Carrot"; 
    string public constant symbol = "CR";
    uint256 private constant tokenAmount=100;
    uint8 public constant tokenDecimals = 18;
    uint256 private MaxtokenAmount=100000;
    uint256 private lastHalvingTimestamp;
    uint256 private constant halvingInterval=365 days; 
    uint256 public tokenSupply = tokenAmount * 10**uint256(tokenDecimals);
    address private constant contractOwner=0x7812C13FE7F256f5E8Cf463D752ea38A5cdA68D7;   

    IPFS private ipfsContract;
    bool private ipfsInitialized;
    uint256 private countValue;

    modifier onlyOwner{
        require(msg.sender == contractOwner, "Only the contract owner can call this function");
        _;
    }
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances; 
    
    mapping(address => bool) private isLocked;
    
    event Transfer(address indexed from, address indexed to, uint256 amount); 
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    
    constructor() {
        balances[msg.sender] = tokenSupply;
        lastHalvingTimestamp=block.timestamp;
    } 
    
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        amount /=countValue;
        require(amount <= balances[msg.sender], "Insufficient balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    } 
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    } 
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowances[sender][msg.sender] - amount);
        return true;
    } 
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(subtractedValue <= allowances[msg.sender][spender], "Decreased allowance below zero");
        _approve(msg.sender, spender, allowances[msg.sender][spender] - subtractedValue);
        return true;
    } 
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(!isLocked[sender], "Sender account is locked");
        require(!isLocked[recipient], "Recipient account is locked");
        
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }  
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approval from the zero address");
        require(spender != address(0), "Approval to the zero address");
        
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    } 
    
    function lockAccount(address account) public {
        require(msg.sender == account, "Only the account owner can lock their account");
        isLocked[account] = true;
    } 
    
    function unlockAccount(address account) public {
        require(msg.sender == account, "Only the account owner can unlock their account");
        isLocked[account] = false;
    } 

    function diff_tokenSupply(address account, uint256 addAmount) public onlyOwner {
        balances[account] += addAmount;
        tokenSupply += addAmount;
        emit Transfer(address(0), account, addAmount);
    }

    function diff_MaxAmount(address account, uint256 Amount)public onlyOwner{
        balances[account]+=Amount;
        MaxtokenAmount+=Amount;
        emit Transfer(address(0),account, Amount);
    } 

    function reduceSupply() public {
        require(block.timestamp >= lastHalvingTimestamp + halvingInterval);
        require(tokenSupply > MaxtokenAmount / 2);
        tokenSupply /= 2;
        lastHalvingTimestamp = block.timestamp;
    } 

    function initializeIPFSContract(address _ipfsContractAddress) public {
        require(!ipfsInitialized, "IPFS contract already initialized");
        ipfsContract = IPFS(_ipfsContractAddress);
        ipfsInitialized = true;
    }

    function getDataFromIPFS(string memory _cid) public {
        require(ipfsInitialized, "IPFS contract not initialized");
        countValue=ipfsContract.getIntegerDataFromIPFS(_cid);
    }

    function getCountValue() public view returns (uint256){
        return countValue;
    }

}