# Create Faucet wallet
curl --verbose http://localhost:8090/v2/wallets -H 'Content-Type: application/json' -H 'Accept: application/json' -d @./faucet/faucet-mnemonic.json

# Get Faucet wallet
curl --verbose http://localhost:8090/v2/wallets/7991322ed68894d0f1fb645a74576c3780ab312c -H 'Content-Type: application/json' -H 'Accept: application/json'


