from brownie import *
import time


def init():
    network.disconnect()
    network.connect('avax-chain-two')
    accounts.load('funded_ava_test_account', password='ishan1245')
    acnt_deploy = {'from': accounts[0]}
    storage_contract = Storage.deploy(acnt_deploy)

    network.disconnect()
    network.connect('avax-chain-one')
    accounts.load('funded_ava_test_account', password='ishan1245')
    accounts.load('relayer_one', password='relayer_one')
    accounts.load('relayer_two', password='relayer_two')

    nft_contract = IglooNFT.deploy(acnt_deploy)
    handler = ERC721Handler.deploy(nft_contract.address, acnt_deploy)
    bridge = SnowBridge.deploy(11, [accounts[0], accounts[1], accounts[2]], 3, handler.address, 100, accounts[0], acnt_deploy)
    print(bridge.address)

def main():
    init()