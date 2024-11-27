// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract DeployRaffle is Script {
    function run() external {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        // Implementation will go here
        HelperConfig Helperconfig = new HelperConfig();
        //local-deploy mocks get local config
        //sepolia get sepolia config

        HelperConfig.NetworkConfig memory config = Helperconfig.getConfig();

        if (config.subscriptionId == 0) {
            // create subscription
            // CreateSubscription createSubscription = new CreateSubscription();
            // (uint256 subId, address vrfCoordinator) = createSubscription
            //     .createSubscription(config.vrfCoordinator);
            // config.subscriptionId = uint64(subId);
            // config.vrfCoordinator = vrfCoordinator;

            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription
                .createSubscription(config.vrfCoordinator, config.account);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.linkToken,
                config.account
            );
        }

        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
            // LinkToken(config.linkToken)
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId,
            config.account
        );
        return (raffle, Helperconfig);
    }
}
