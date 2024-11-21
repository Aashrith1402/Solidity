// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SecureWithdrawal {
    // Address of the contract owner
    address public owner;
    // Maximum amount allowed to withdraw per transaction
    uint public maxWithdrawAmount;
    // Cooldown period in seconds
    uint public withdrawalCooldown;
    // Last withdrawal timestamp for the owner
    uint private lastWithdrawalTimestamp;
    // Event to log withdrawals
    event Withdrawal(address indexed to, uint amount);
    // Modifier to allow only the owner to call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    // Constructor to initialize owner, max withdrawal amount, and cooldown
    constructor(uint _maxWithdrawAmount, uint _withdrawalCooldown) {
        owner = msg.sender;  // Set the deployer as the contract owner
        maxWithdrawAmount = _maxWithdrawAmount;
        withdrawalCooldown = _withdrawalCooldown;
    }
    // Function to receive Ether directly into the contract
receive() external payable {}
    // Function for the owner to withdraw funds with security restrictions
    function withdraw(uint amount) external onlyOwner {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= maxWithdrawAmount, "Exceeds maximum withdraw limit");
        require(address(this).balance >= amount, "Insufficient contract balance");
        require(
            block.timestamp >= lastWithdrawalTimestamp + withdrawalCooldown,
            "Cooldown period not yet passed"
        );
        // Update the last withdrawal timestamp
        lastWithdrawalTimestamp = block.timestamp;

        // Transfer the specified amount to the owner
        payable(owner).transfer(amount);

        // Emit an event for logging purposes
        emit Withdrawal(owner, amount);
    }
    // Function for the owner to change the maximum withdrawal amount
    function setMaxWithdrawAmount(uint _maxWithdrawAmount) external onlyOwner {
        maxWithdrawAmount = _maxWithdrawAmount;
    }
    // Function for the owner to set a cooldown period for withdrawals
    function setWithdrawalCooldown(uint _withdrawalCooldown) external onlyOwner {
        withdrawalCooldown = _withdrawalCooldown;
    }
    // Helper function to check the contract balance
    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }
}
