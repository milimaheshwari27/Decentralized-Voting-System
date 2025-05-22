const hre = require("hardhat");

async function main() {
  console.log("Starting deployment of Decentralised Crowdfunding Platform...");
  
  // Get the ContractFactory and Signers here
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());
  
  // Deploy the contract
  console.log("Deploying Project contract (Crowdfunding Platform)...");
  
  const Project = await hre.ethers.getContractFactory("Project");
  const project = await Project.deploy();
  
  await project.waitForDeployment();
  
  const contractAddress = await project.getAddress();
  console.log("Project contract deployed to:", contractAddress);
  
  // Verify deployment
  console.log("\nVerifying deployment...");
  const platformOwner = await project.platformOwner();
  const campaignCounter = await project.campaignCounter();
  const totalCampaigns = await project.totalCampaigns();
  const platformFeePercentage = await project.platformFeePercentage();
  const totalFundsRaised = await project.totalFundsRaised();
  
  console.log("Platform Owner:", platformOwner);
  console.log("Campaign Counter:", campaignCounter.toString());
  console.log("Total Campaigns:", totalCampaigns.toString());
  console.log("Platform Fee Percentage:", platformFeePercentage.toString(), "basis points");
  console.log("Total Funds Raised:", hre.ethers.formatEther(totalFundsRaised), "ETH");
  
  // Get platform stats
  const [totalCampaignsStats, totalFundsStats, activeCampaigns] = await project.getPlatformStats();
  console.log("Active Campaigns:", activeCampaigns.toString());
  
  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: contractAddress,
    platformOwner: platformOwner,
    platformFeePercentage: platformFeePercentage.toString(),
    deploymentTime: new Date().toISOString(),
    transactionHash: project.deploymentTransaction().hash,
    gasUsed: project.deploymentTransaction().gasLimit?.toString() || "N/A"
  };
  
  console.log("\n=== Deployment Summary ===");
  console.log(JSON.stringify(deploymentInfo, null, 2));
  
  console.log("\n=== Contract Functions Available ===");
  console.log("Core Functions:");
  console.log("1. createCampaign(title, description, targetAmount, durationInDays)");
  console.log("2. contribute(campaignId) - send ETH with this transaction");
  console.log("3. withdrawFunds(campaignId) - for successful campaigns");
  console.log("4. requestRefund(campaignId) - for failed campaigns");
  
  console.log("\nView Functions:");
  console.log("- getCampaign(campaignId)");
  console.log("- getContribution(campaignId, contributorAddress)");
  console.log("- getCampaignContributors(campaignId)");
  console.log("- isCampaignSuccessful(campaignId)");
  console.log("- getPlatformStats()");
  
  console.log("\n=== Platform Configuration ===");
  console.log(`Platform Fee: ${platformFeePercentage.toString()} basis points (${(Number(platformFeePercentage) / 100).toFixed(2)}%)`);
  console.log("Maximum Campaign Duration: 365 days");
  console.log("Maximum Platform Fee: 10%");
  
  console.log("\n=== Usage Examples ===");
  console.log("// Create a campaign for 1 ETH with 30 days duration");
  console.log(`await contract.createCampaign("My Project", "Description", ethers.parseEther("1"), 30);`);
  console.log("");
  console.log("// Contribute 0.1 ETH to campaign ID 1");
  console.log(`await contract.contribute(1, { value: ethers.parseEther("0.1") });`);
  console.log("");
  console.log("// Withdraw funds after successful campaign");
  console.log(`await contract.withdrawFunds(1);`);
  
  console.log("\n=== Next Steps ===");
  console.log("1. Create test campaigns using createCampaign()");
  console.log("2. Test contributions with contribute()");
  console.log("3. Test fund withdrawal for successful campaigns");
  console.log("4. Test refund mechanism for failed campaigns");
  console.log("5. Monitor platform statistics with getPlatformStats()");
  
  return {
    contract: project,
    address: contractAddress,
    deploymentInfo: deploymentInfo
  };
}

// Handle errors
main()
  .then((result) => {
    console.log("\nDeployment completed successfully!");
    console.log("Contract ready for crowdfunding campaigns!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Deployment failed:");
    console.error(error);
    process.exit(1);
  });
