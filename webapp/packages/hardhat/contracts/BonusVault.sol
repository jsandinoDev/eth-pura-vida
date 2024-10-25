// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";


contract BonusVault is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 subscriptionId;
    address vrfCoordinator;
    bytes32 keyHash;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256[] public randomWords;
    uint256 public requestId;

    address public client;
    address public freelancer;
    uint256 public projectAmount;
    bool public projectCompleted;

    uint256 public bonusPercentage;
    bool public bonusEligible;

    event EscrowCreated(address indexed client, address indexed freelancer, uint256 projectAmount);
    event ProjectCompleted(address indexed freelancer, uint256 payout, bool bonusApplied);
    event BonusDetermined(uint256 bonusPercentage);
    event APIRequestEscrowCreation(address indexed client, address indexed freelancer, uint256 projectAmount);
    event APIEscrowCompleted(uint256 escrowId, address indexed freelancer);

    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
    }

    function createEscrow(address _freelancer) external payable {
        require(msg.value > 0, "Must deposit funds for the project");
        client = msg.sender;
        freelancer = _freelancer;
        projectAmount = msg.value;
        projectCompleted = false;

        // Emit event to trigger off-chain API to create escrow
        emit APIRequestEscrowCreation(client, freelancer, projectAmount);
    }

    // This function should be called by the off-chain system after escrow is created in Trustless Work
    function confirmEscrowCreation(uint256 escrowId) external {
        // Logic for confirming escrow creation in the smart contract if needed
    }

    function completeProject(uint256 escrowId) external {
        require(msg.sender == client, "Only the client can confirm completion");
        require(!projectCompleted, "Project already completed");

        projectCompleted = true;

        // Emit event to trigger off-chain API to complete escrow
        emit APIEscrowCompleted(escrowId, freelancer);

        // Request randomness for bonus determination
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(projectCompleted, "Project not completed yet");

        randomWords = _randomWords;
        bonusPercentage = (randomWords[0] % 11);

        emit BonusDetermined(bonusPercentage);

        releaseFunds();
    }

    function releaseFunds() internal {
        require(projectCompleted, "Project is not completed yet");

        uint256 totalPayout = projectAmount;
        if (bonusPercentage > 0) {
            uint256 bonus = (projectAmount * bonusPercentage) / 100;
            totalPayout += bonus;
            bonusEligible = true;
        }

        payable(freelancer).transfer(totalPayout);
        emit ProjectCompleted(freelancer, totalPayout, bonusEligible);
    }
}