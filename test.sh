#!/bin/bash

# Function to display the opening message in green
display_welcome_message() {
  echo -e "\x1b[32m========================="
  echo -e "BOT AUTO TX TEA TESTNET"
  echo -e "by Bimo"
  echo -e "t.me/garapanbimo"
  echo -e "========================="
  echo -e "Donation for buying me a cup of coffee"
  echo -e "(EVM) : 0x48baa3ACE7CdDeE47C100e87A0FC0A653258eb55"
  echo -e "(SOLANA) : 3mSmt3fLQdP1eG8JH9fGTU2Wm3Z2HSs2fbaf1KyPjUq7"
  echo -e "========================="
  echo -e "Thank you!"
  echo -e "Enjoy"
  echo -e "\x1b[0m"  # Reset to normal text color
}

# Function to check if Node.js is installed and install it if necessary
install_nodejs() {
  if ! command -v node &> /dev/null
  then
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - > /dev/null 2>&1
    sudo apt-get install -y nodejs > /dev/null 2>&1
  fi
}

# Function to install jq (for JSON manipulation)
install_jq() {
  if ! command -v jq &> /dev/null
  then
    sudo apt-get install -y jq > /dev/null 2>&1
  fi
}

# Function to install project dependencies (including axios, node-cron, dotenv, ethers.js)
install_dependencies() {
  npm install --save axios node-cron dotenv ethers > /dev/null 2>&1
}

# Function to create .env file with fixed RPC URL and prompt for the API key
create_env_file() {
  echo "Creating .env file..."

  # Writing the fixed Tea Sepolia public RPC URL to .env
  echo "TEA_RPC_URL=https://tea-sepolia.g.alchemy.com/public" > .env
  echo "TEA_CHAIN_ID=10218" >> .env
  echo "TEA_CURRENCY_SYMBOL=TEA" >> .env

  # Prompt for the private Alchemy API key
  echo -e "\x1b[32mPlease enter your Alchemy API key:\x1b[0m"
  read apiKey
  echo "ALCHEMY_API_KEY=$apiKey" >> .env

  echo ".env file created with Tea Sepolia public network details and Alchemy API key."
}

# Function to fetch the current gas price in Gwei from the Sepolia Gas Tracker
fetch_current_gas_price() {
  echo "Fetching current gas price from Sepolia Gas Tracker..."
  gas_price=$(curl -s https://sepolia.tea.xyz/gas-tracker | jq '.fast')
  echo "Current gas price: $gas_price Gwei"
  echo $gas_price
}

# Function to create bot.js automatically with Tea Sepolia RPC details
create_bot_js() {
  echo "Creating bot.js file..."
  cat > bot.js <<EOL
const axios = require('axios');
const cron = require('node-cron');
require('dotenv').config();
const fs = require('fs');
const { ethers } = require('ethers');

// Load RPC URL, Chain ID, and Currency from .env
const TEA_RPC_URL = process.env.TEA_RPC_URL;
const TEA_CHAIN_ID = process.env.TEA_CHAIN_ID;
const TEA_CURRENCY_SYMBOL = process.env.TEA_CURRENCY_SYMBOL;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const TRANSACTION_AMOUNT = process.env.TRANSACTION_AMOUNT || '0.05';  // Read from .env

// Load wallets from file (if exists)
const loadWallets = () => {
  if (fs.existsSync('wallets.json')) {
    const rawData = fs.readFileSync('wallets.json');
    return JSON.parse(rawData);
  } else {
    return []; // No wallets file, return empty array
  }
};

// Load recipients from file (if exists)
const loadRecipients = () => {
  if (fs.existsSync('recipients.json')) {
    const rawData = fs.readFileSync('recipients.json');
    return JSON.parse(rawData);
  } else {
    return []; // No recipients file, return empty array
  }
};

// Function to send a transaction using Tea Sepolia RPC
const sendTransaction = async (wallet, recipient, amount, gasPrice) => {
  try {
    // Ensure the amount is formatted correctly as a string, and then convert to Wei (18 decimals for TEA)
    const weiAmount = ethers.parseUnits(amount.toString(), 18); // Convert TEA to Wei

    const provider = new ethers.JsonRpcProvider(TEA_RPC_URL);
    const signer = new ethers.Wallet(wallet.privateKey, provider);

    const transaction = {
      to: recipient,
      value: weiAmount,
      gasLimit: 21000,
      gasPrice: ethers.parseUnits(gasPrice.toString(), 'gwei'),
    };

    const txResponse = await signer.sendTransaction(transaction);

    const balance = await getBalance(wallet.address);

    console.log("Wallet Address: \x1b[1m\x1b[30m" + wallet.address + "\x1b[0m");
    console.log("Wallet balance : \x1b[33m" + balance + " " + TEA_CURRENCY_SYMBOL + "\x1b[0m");
    console.log("Transactions : \x1b[32mOK\x1b[0m");
    console.log("TX Hash: \x1b[32m" + txResponse.hash + "\x1b[0m");
    console.log("++++++++++++++++++++++++++++");
  } catch (error) {
    console.error('Transaction Failed:', error.message);
  }
};

// Function to fetch the wallet balance
const getBalance = async (address) => {
  try {
    const provider = new ethers.JsonRpcProvider(TEA_RPC_URL);
    const balance = await provider.getBalance(address);
    return ethers.formatUnits(balance, 18);
  } catch (error) {
    console.error('Failed to fetch balance:', error.message);
    return 0;
  }
};

// Function to start the bulk sending process with 1-minute intervals
const startBulkSend = async () => {
  let walletIndex = 0;
  let recipientIndex = 0;
  const wallets = loadWallets();
  const recipients = loadRecipients();

  // Fetch current gas price before starting
  const gasPrice = await axios.get('https://sepolia.tea.xyz/gas-tracker').then(response => response.data.fast);

  cron.schedule('* * * * *', async () => {
    if (walletIndex < wallets.length && recipientIndex < recipients.length) {
      await sendTransaction(wallets[walletIndex], recipients[recipientIndex], TRANSACTION_AMOUNT, gasPrice);
      walletIndex++;
      recipientIndex++;

      if (walletIndex >= wallets.length) walletIndex = 0;
      if (recipientIndex >= recipients.length) recipientIndex = 0;
    } else {
      console.log('No more transactions to send.');
    }
  });

  console.log('Bulk sending started with 1-minute intervals.');
};

// Start the bulk sending process
startBulkSend();
EOL
  echo "bot.js has been created."
}

# Function to input transaction amount (nominal balance) and save to .env
create_transaction_amount() {
  echo "Please enter the nominal amount to send per transaction:"
  read transactionAmount
  echo "TRANSACTION_AMOUNT=$transactionAmount" >> .env  # Save to .env
  echo -e "\x1b[32mTransaction amount set to: $transactionAmount TEA\x1b[0m"  # Set to green color
}

# Function to run the bot in the foreground (on screen)
run_bot_in_foreground() {
  echo "BOT is running..."
  node bot.js
}

# Start the installation and setup process
display_welcome_message  # Show the welcome message

echo -e "\x1b[32mStarting one-click installer...\x1b[0m"

# Run installation steps with spinner animation
{
  install_nodejs &
  install_jq &
  install_dependencies &
  wait  # Wait for all background processes to finish
}

# Step 4: Create the .env file with Tea Sepolia public network details and fixed public RPC URL
create_env_file

# Step 5: Create the wallets.json file and add wallet data (one by one)
create_wallets_file

# Step 6: Check and convert recipients.txt to recipients.json (if exists)
convert_recipients_to_json

# Step 7: Ask for transaction amount and save it to .env
create_transaction_amount

# Step 8: Create the bot.js file
create_bot_js

# Step 9: Run the bot in the foreground
run_bot_in_foreground

echo "The bot is running on your screen. You can check its output directly in the terminal."
