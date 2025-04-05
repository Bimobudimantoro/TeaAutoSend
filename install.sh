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
  echo -e ""
  echo -e "(SOLANA) : 3mSmt3fLQdP1eG8JH9fGTU2Wm3Z2HSs2fbaf1KyPjUq7"
  echo -e "========================="
  echo -e "Thank you!"
  echo -e "Enjoy"
  echo -e "\x1b[0m"  # Reset to normal text color
}

# Function to check and convert recipients.txt to recipients.json
convert_recipients_txt_to_json() {
  if [ -f recipients.txt ]; then
    echo -e "\x1b[32mChecking recipients.txt... Found! Converting to recipients.json...\x1b[0m"

    # Read recipients from recipients.txt, convert to JSON array
    recipients=$(awk '{print "\"" $0 "\""}' recipients.txt | paste -sd, -)
    echo "[$recipients]" > recipients.json

    echo -e "\x1b[32mRecipient addresses have been converted to recipients.json.\x1b[0m"
  else
    echo -e "\x1b[31mrecipients.txt not found. Please create a recipients.txt file with one address per line.\x1b[0m"
  fi
}

# Function to install project dependencies
install_dependencies() {
  echo "Installing project dependencies..."
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

# Function to input private key and wallet address (one by one) and convert to JSON
create_wallets_file() {
  if [ ! -f wallets.json ]; then
    echo "Creating wallets.json file..."
    echo "[]" > wallets.json
  fi

  while true; do
    echo "Please enter private key (or type 'save' to finish):"
    read privateKey
    if [ "$privateKey" == "save" ]; then
      break
    fi

    # Derive wallet address from the private key using ethers.js
    walletAddress=$(node -e "
      const { ethers } = require('ethers');
      const wallet = new ethers.Wallet('$privateKey');
      console.log(wallet.address);
    ")

    echo "Wallet address derived from private key: $walletAddress"

    # Save the wallet data to wallets.json
    wallets=$(cat wallets.json)
    wallets=$(echo $wallets | jq ". + [{\"address\": \"$walletAddress\", \"privateKey\": \"$privateKey\"}]")
    echo $wallets > wallets.json
    echo -e "\x1b[32mWallet saved successfully!\x1b[0m" # Green color for success message
  done
}

# Function to prompt user to select TEA or another token
choose_token_type() {
  echo -e "\x1b[32mPlease select the token to transfer (TEA or Another):\x1b[0m"
  echo "1) TEA"
  echo "2) Another Token"
  read -p "Enter your choice (1 or 2): " token_choice

  if [ "$token_choice" == "1" ]; then
    echo -e "\x1b[32mYou selected TEA.\x1b[0m"
    export TOKEN_TYPE="TEA"
  elif [ "$token_choice" == "2" ]; then
    echo -e "\x1b[32mYou selected another token.\x1b[0m"
    read -p "Please enter the contract address of the token: " contract_address
    export TOKEN_TYPE="Another"
    export CONTRACT_ADDRESS="$contract_address"
    echo -e "\x1b[32mContract address saved: $CONTRACT_ADDRESS\x1b[0m"
  else
    echo -e "\x1b[31mInvalid choice, please select 1 or 2.\x1b[0m"
    choose_token_type  # Recursively call the function if invalid input
  fi
}

# Function to create bot.js file automatically with Tea Sepolia RPC details
create_bot_js() {
  echo "Creating bot.js file..."
  cat > bot.js <<EOL
const { ethers } = require('ethers');
require('dotenv').config();
const fs = require('fs');
const axios = require('axios');

// Load the .env variables
const TEA_RPC_URL = process.env.TEA_RPC_URL;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const TOKEN_TYPE = process.env.TOKEN_TYPE;  // TEA or Another
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS; // ERC-20 token address if 'Another'

// Set up provider
const provider = new ethers.JsonRpcProvider(TEA_RPC_URL);

// Function to send TEA or another token
const sendTransaction = async (wallet, recipient, amount) => {
  try {
    const signer = new ethers.Wallet(wallet.privateKey, provider);

    // If the token type is TEA (native token)
    if (TOKEN_TYPE === 'TEA') {
      const weiAmount = ethers.parseUnits(amount.toString(), 18); // Converting to Wei

      const tx = await signer.sendTransaction({
        to: recipient,
        value: weiAmount, // For native TEA
      });

      console.log(\`TX Hash: \${tx.hash}\`);
      await tx.wait();
      console.log('Transaction confirmed: Success');
    } 
    // If the token type is "Another" (ERC-20 token)
    else if (TOKEN_TYPE === 'Another') {
      const tokenContract = new ethers.Contract(CONTRACT_ADDRESS, [
        'function transfer(address recipient, uint256 amount) public returns (bool)',
      ], signer);

      const tokenAmount = ethers.parseUnits(amount.toString(), 18); // Assuming 18 decimals for the token

      const tx = await tokenContract.transfer(recipient, tokenAmount);
      console.log(\`TX Hash: \${tx.hash}\`);
      await tx.wait();
      console.log('Transaction confirmed: Success');
    } else {
      console.log('Invalid token type.');
    }

  } catch (error) {
    console.error('Transaction failed:', error.message);
  }
};

// Example usage
const wallets = require('./wallets.json');
const recipient = 'recipient_wallet_address'; // Replace with actual recipient address
const amount = '0.05'; // Replace with the amount of TEA or other token you want to send

wallets.forEach(wallet => {
  sendTransaction(wallet, recipient, amount);
});
EOL
  echo "bot.js has been created."
}

# Function to input transaction amount (nominal balance)
create_transaction_amount() {
  echo "Please enter the nominal amount to send per transaction:"
  read transactionAmount
  echo -e "\x1b[32mTransaction amount set to: $transactionAmount TEA\x1b[0m"
}

# Run the bot in the foreground
run_bot_in_foreground() {
  echo "BOT is running..."
  node bot.js
}

# Start the installation and setup process
display_welcome_message  # Show the welcome message

echo -e "\x1b[32mStarting one-click installer...\x1b[0m"

# Run installation steps
install_dependencies

# Create .env, wallets, bot.js, etc.
create_env_file
create_wallets_file
choose_token_type  # Select token type (TEA or Another)
convert_recipients_txt_to_json  # Convert recipients.txt to recipients.json
create_bot_js
create_transaction_amount

# Run the bot
run_bot_in_foreground
