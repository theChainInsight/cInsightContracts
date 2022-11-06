// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import {ChainInsightLogicV1} from "src/governance/LogicV1.sol";
import {ChainInsightExecutorV1} from "src/governance/ExecutorV1.sol";
import {ChainInsightGovernanceProxyV1} from "src/governance/ProxyV1.sol";
import {Bonfire} from "src/bonfire/Bonfire.sol";
import {BonfireImp} from "src/bonfire/BonfireImp.sol";
import {SkinNft} from "src/skinnft/SkinNft.sol";
import {ISkinNft} from "src/skinnft/ISkinNft.sol";

contract cInsightScript is Script {
    ChainInsightLogicV1 logic;
    ChainInsightExecutorV1 executor;
    ChainInsightGovernanceProxyV1 proxy;
    Bonfire bonfire;
    BonfireImp bonfireImp;
    SkinNft skinNft;
    uint256 executingGracePeriod = 300;
    uint256 executingDelay = 150;
    uint256 votingPeriod = 150;
    uint256 votingDelay = 1;
    uint8 proposalThreshold = 1;
    string baseURL = "https://thechaininsight.github.io/";

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // excute operations as a deployer account until stop broadcast
        vm.startBroadcast(deployerPrivateKey);

        logic = new ChainInsightLogicV1();
        executor = new ChainInsightExecutorV1();
        bonfire = new Bonfire();
        bonfireImp = new BonfireImp();
        skinNft = new SkinNft(string.concat(baseURL, "skinnft/"));
        address admin = tx.origin;
        address vetoer = address(0);

        proxy = new ChainInsightGovernanceProxyV1(
            address(logic),
            address(executor),
            address(bonfire),
            vetoer,
            executingGracePeriod,
            executingDelay,
            votingPeriod,
            votingDelay,
            proposalThreshold
        );

        executor.setProxyAddress(address(proxy));

        bonfire.init(
            address(executor),
            "ChainInsight",
            "SBT",
            string.concat(baseURL, "bonfire/metadata/"),
            0.05 ether,
            address(skinNft),
            address(bonfireImp)
        );
        skinNft.init(address(bonfire));

        vm.stopBroadcast();
    }
}