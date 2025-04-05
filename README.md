2. What the Script Does
The install.sh script automates the entire setup process for you. Here's a breakdown of the actions performed by the script:

Installs dependencies:

Automatically installs the required Node.js dependencies (ethers.js, axios, node-cron, dotenv) using npm install.

Prompts for Alchemy API key:

The script will ask for your Alchemy API key to connect to the Tea Sepolia testnet.

Enter wallet private keys:

You will be prompted to enter private keys for the wallets you want to use (one by one). These will be saved to wallets.json.
Creates wallets.json:

Wallet addresses and their corresponding private keys are saved to a wallets.json file for the bot to use.

Enter transaction amount:

You will be asked to enter the nominal amount in TEA to send per transaction.

Starts the transaction bot:

Once the setup is complete, the bot will start sending transactions at 1-minute intervals to the recipients you specify in the recipients.json file.

3. What Happens Next
After the script runs successfully:

The bot will begin sending transactions automatically at 1-minute intervals.

It logs the transaction results, including the TX hash and the wallet balance after each transaction.
If there are any errors (e.g., insufficient funds or invalid wallet address), the bot will log those as well.

How to Use the Bot
Once you've installed and configured the bot:

The bot will start automatically and send transactions at 1-minute intervals.

You can modify the wallet addresses and private keys by editing the wallets.json file.

You can also add recipient addresses by creating a recipients.txt file, with one address per line. This file will be automatically converted to recipients.json.
