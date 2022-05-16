from brownie import *
import time

# relayer_one --> relayer_one
# relayer_two --> relayer_two

class IglooRelayer:
  def __init__(self, event_chain, contract_chain, bridge_address, account_name, account_password):
      self.bridge_address = bridge_address
      self.event_chain = event_chain
      self.contract_chain = contract_chain
      self.account_name = account_name
      self.account_password = account_password

      network.disconnect()
      network.connect(event_chain)
      accounts.load(account_name, password=account_password)
      self.old_chain_height = chain.height

  def vote_proposal(self, event):
      network.disconnect()
      network.connect(self.contract_chain)

      key = event['key']
      user_address = event['userAddress']
      bridge = SnowBridge.at(self.bridge_address)
      accounts.load(self.account_name, password=self.account_password)

      bridge.voteProposal(user_address, key, {'from': accounts[0]})

      network.disconnect()
      network.connect(self.event_chain)

  def monitor(self):
      if network.show_active() != self.event_chain:
          network.disconnect()
          network.connect(self.event_chain)
    
      curr_chain_height = chain.height
      for tx_number in range(self.old_chain_height, curr_chain_height):
          tx_id = chain[tx_number]['transactions'][0].hex()
          print(tx_id)
          tx = chain.get_transaction(tx_id)
          if len(tx.events) != 0: # Make this reflect the right format
              print("ENTER")
              print(tx.events)
              self.vote_proposal(tx.events[0])
      self.old_chain_height = curr_chain_height


def main():
    event_chain = 'avax-chain-two'
    contract_chain = 'avax-chain-one'
    bridge_address = '0xfd47F24A11c3e35ED7E9815C161c180b435697C3'
    account_name = 'relayer_two'
    account_password = 'relayer_two'

    relayer = IglooRelayer(event_chain, contract_chain, bridge_address, account_name, account_password)

    while True:
        time.sleep(15)
        print("MONITOR")
        relayer.monitor()