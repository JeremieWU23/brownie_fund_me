from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)
from brownie.network.gas.strategies import LinearScalingStrategy
import time
from web3 import Web3


def deploy_fund_me():
    account = get_account()
    # print(accounts[0].balance(), accounts[1])
    # Pass the pricefeed address to our fundme contract through deploy function

    # If we are on a persistent network like sepolia, use the associated address
    # Otherwise, deploy mocks
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        # move into function
        deploy_mocks()
        # [-1] is the most recent contract deployed
        price_feed_address = MockV3Aggregator[-1].address

    # gas_strategy = LinearScalingStrategy("60 gwei", "70 gwei", 1.1)
    # network.gas_price(gas_strategy)

    fund_me = FundMe.deploy(
        price_feed_address,
        {
            "from": account,
            # "gas_price": gas_strategy
        },
        # [] & .get can both work, if other networks have no "verify" in config then use .get(). If all have, both of these can be used
        publish_source=config["networks"][network.show_active()].get("verify"),
    )

    time.sleep(1)
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
