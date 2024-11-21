// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract RentalContract {
    // The address of the owner (landlord) who deploys the contract
    address public owner;
    // Struct to represent a rental agreement
    struct RentalAgreement {
        address tenant;    // Address of the tenant
        uint deposit;      // Amount of deposit submitted by the tenant
        bool isActive;     // State of the agreement (active or inactive)
    }
    // Mapping to store multiple rental agreements between the owner and tenants
    mapping(uint => RentalAgreement) public agreements;
    // A counter to assign a unique ID to each rental agreement
    uint public agreementCounter;
    // Event to notify when a new agreement is created
    event AgreementCreated(uint agreementId, address indexed tenant, uint deposit);
    // Event to notify when a deposit is submitted by the tenant
    event DepositSubmitted(uint agreementId, uint amount);
    // Modifier to restrict certain functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    // Modifier to restrict certain functions to the tenant of a specific agreement
    modifier onlyTenant(uint agreementId) {
        require(msg.sender == agreements[agreementId].tenant, "Only the tenant can perform this action");
        _;
    }
    // Constructor to set the owner as the account that deploys the contract
    constructor() {
        owner = msg.sender;
    }
    // Function to create a new rental agreement
    // The owner can create a contract by providing the tenant's address and initial deposit
    function createAgreement(address _tenant) public onlyOwner {
        // Increment the agreement counter to get a unique ID
        agreementCounter++;
        // Create a new rental agreement and store it in the mapping
        agreements[agreementCounter] = RentalAgreement({
            tenant: _tenant,
            deposit: 0,  // Initially, no deposit is submitted
            isActive: true  // Agreement is active upon creation
        });
        
        // Emit event to notify that a new agreement has been created
        emit AgreementCreated(agreementCounter, _tenant, 0);
    }
    // Function for the tenant to submit a deposit to the rental agreement
    function submitDeposit(uint agreementId) public payable onlyTenant(agreementId) {
        // Ensure that the agreement is active
        require(agreements[agreementId].isActive, "Rental agreement is not active");
        // Add the submitted amount to the deposit balance
        agreements[agreementId].deposit += msg.value;
        // Emit event to notify that a deposit has been submitted
        emit DepositSubmitted(agreementId, msg.value);
    }
    // Function for the owner to check the balance (deposit) of a specific rental agreement
    function checkAgreementBalance(uint agreementId) public view returns (uint) {
        // Ensure the agreement exists
        require(agreementId <= agreementCounter, "Agreement does not exist");
        // Return the deposit amount of the agreement
        return agreements[agreementId].deposit;
    }
    // Function to end the rental agreement
    // Only the owner can end the agreement
    function endAgreement(uint agreementId) public onlyOwner {
        // Ensure that the agreement is still active
        require(agreements[agreementId].isActive, "Agreement is already inactive");
        // Mark the agreement as inactive
        agreements[agreementId].isActive = false;
    }
 // Function to withdraw the tenant's deposit
    // Only the owner can withdraw funds (typically after agreement ends)
    function withdrawDeposit(uint agreementId) public onlyOwner {
        // Ensure that the agreement is inactive
        require(!agreements[agreementId].isActive, "Cannot withdraw while agreement is active");
        // Ensure there is a deposit to withdraw
        uint depositAmount = agreements[agreementId].deposit;
        require(depositAmount > 0, "No deposit to withdraw");
        // Reset the deposit balance before transfer to prevent re-entrancy attacks
        agreements[agreementId].deposit = 0;
        // Transfer the deposit to the owner
        payable(owner).transfer(depositAmount);
    }
}
