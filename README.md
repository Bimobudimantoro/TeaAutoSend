```markdown
# BOT AUTO TX TEA TESTNET

This project automates sending transactions using the **Tea Sepolia testnet**.

## Overview

This bot sends transactions automatically on the **Tea Sepolia** testnet. It uses **ethers.js** and **Node.js** to connect with the **Tea Sepolia RPC** and sends transactions from a list of wallet addresses to a list of recipients. You can easily set it up with a single script.

## Requirements

Before you run the bot, make sure you have the following:
- **Node.js** installed (version >= 14.x).
- **A GitHub account** (for cloning the repository, if needed).
- **A Tea Sepolia RPC endpoint** (you can get this from [Alchemy](https://www.alchemy.com/)).

## How to Install & Run

### 1. Clone the Repository (or download `install.sh` directly)

You can directly download the `install.sh` script from GitHub.

Run the following command in your terminal to download the script and start the installation:

```bash
curl -sSL https://github.com/yourusername/auto-tx-install/raw/master/install.sh -o install.sh && chmod +x install.sh && ./install.sh
```

### 2. What the Script Does

The `install.sh` script automates the entire setup process for you. Here's a breakdown of the actions performed by the script:

- **Installs dependencies**: 
   - Automatically installs the required Node.js dependencies (`ethers.js`, `axios`, `node-cron`, `dotenv`) using `npm install`.
   
- **Prompts for Alchemy API key**:
   - The script will ask for your **Alchemy API key** to connect to the Tea Sepolia testnet.

- **Enter wallet private keys**:
   - You will be prompted to enter **private keys** for the wallets you want to use (one by one). These will be saved to `wallets.json`.

- **Creates `wallets.json`**:
   - Wallet addresses and their corresponding private keys are saved to a `wallets.json` file for the bot to use.

- **Enter transaction amount**:
   - You will be asked to enter the **nominal amount** in **TEA** to send per transaction.

- **Starts the transaction bot**:
   - Once the setup is complete, the bot will start sending transactions at **1-minute intervals** to the recipients you specify in the `recipients.json` file.

### 3. What Happens Next

After the script runs successfully:

- The bot will begin sending transactions automatically at 1-minute intervals.
- It logs the transaction results, including the **TX hash** and the **wallet balance** after each transaction.
- If there are any errors (e.g., insufficient funds or invalid wallet address), the bot will log those as well.

## How to Use the Bot

Once you've installed and configured the bot:
- The bot will start automatically and send transactions at 1-minute intervals.
- You can modify the wallet addresses and private keys by editing the **`wallets.json`** file.
- You can also add recipient addresses by creating a `recipients.txt` file, with one address per line. This file will be automatically converted to **`recipients.json`**.

## FAQ

### 1. Can I use my own RPC URL?

Yes! If you have your own RPC URL, you can modify the `.env` file after installation to point to your custom RPC.

### 2. Is it safe to run the bot with my private keys?

While this bot runs locally and your private keys are stored in `wallets.json`, it’s **recommended** to use **testnet wallets** for security. Never use your mainnet private keys.

### 3. How can I stop the bot?

You can stop the bot by pressing `Ctrl + C` in the terminal.

### 4. Can I change the transaction amount?

Yes! During setup, you'll be prompted to enter the amount of TEA you want to send per transaction.

## Donation for Coffee ☕

If you found this bot useful and would like to support me, you can make a small donation for a cup of coffee:

- **EVM (Ethereum)**: `0x48baa3ACE7CdDeE47C100e87A0FC0A653258eb55`
- **SOLANA**: `3mSmt3fLQdP1eG8JH9fGTU2Wm3Z2HSs2fbaf1KyPjUq7`

Thank you for your support!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

4. **Commit the File**:
   - After pasting the content above, scroll down and click the **"Commit new file"** button.

This will create the `README.md` directly on GitHub with the correct formatting.

### Users Can Now:
- Directly download `install.sh` using the `curl` command from GitHub.
- Run the installation with a **single command** and start using your bot.

Let me know if you need any further guidance!
