# eth-pura-vida


# Trustless Escrow with Randomized Bonus - Smart Contract & Trustless Work API Integration

## Project Overview:

### Idea:
- Build an escrow platform using Trustless Work's API for core escrow functionalities.
- Introduce a bonus feature where Chainlink VRF is used to randomly determine if a freelancer receives a bonus after successful project completion.

## API Integration Plan:
Since smart contracts cannot directly interact with external APIs, we will use an **off-chain service** to manage communication between the smart contract and the Trustless Work API.

### Off-chain Service:
The service will:
1. Listen to events emitted by the smart contract.
2. Communicate with the Trustless Work API to handle escrow creation, completion, etc.
3. Send relevant updates back to the smart contract.

### Smart Contract Changes:
We will modify the smart contract to:
1. Emit events when an escrow is created or completed.
2. Use the off-chain service to listen to these events, trigger API calls, and update the smart contract with the escrow status.

## Key Changes:
1. **Events for Escrow Creation and Completion**:
   - `APIRequestEscrowCreation`: Signals the off-chain service to create an escrow using the Trustless Work API.
   - `APIEscrowCompleted`: Signals the off-chain service to complete the escrow using the API.

2. **Off-chain Service**:
   - The off-chain server will listen to these events and handle API calls, then update the smart contract accordingly.

## Backend (Off-chain) Setup:
- Use **web3.js** or **ethers.js** to listen for smart contract events.
- Once an event is detected, the backend will:
   - Call the Trustless Work API to create or complete the escrow.
   - Call the smart contract to update its state with escrow information from the API.
