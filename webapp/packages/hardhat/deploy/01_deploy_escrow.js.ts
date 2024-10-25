import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployBonusVault: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const subscriptionId = process.env.SUBSCRIPTION_ID; // Your Chainlink subscription ID
  const vrfCoordinator = process.env.VRF_COORDINATOR; // Chainlink VRF Coordinator address
  const keyHash = process.env.KEY_HASH; // Chainlink VRF key hash

  await deploy("BonusVault", {
    from: deployer,
    args: [subscriptionId, vrfCoordinator, keyHash],
    log: true,
  });
};

export default deployBonusVault;