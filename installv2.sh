#!/bin/bash

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
  echo -e "Thank you! Enjoy"
  echo -e "\x1b[0m"
}

install_nodejs() {
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &>/dev/null
  sudo apt-get install -y nodejs &>/dev/null
}

install_jq() {
  sudo apt-get install -y jq &>/dev/null
}

install_dependencies() {
  npm install axios node-cron dotenv ethers@latest &>/dev/null
}

create_env_file() {
  cat > .env <<EOL
TEA_RPC_URL=https://tea-sepolia.g.alchemy.com/public
TEA_CHAIN_ID=10218
TEA_CURRENCY_SYMBOL=TEA
EOL
  read -p "Enter your Alchemy API key: " apiKey
  echo "ALCHEMY_API_KEY=$apiKey" >> .env
}

create_wallets_file() {
  echo "[]" > wallets.json
  while true; do
    read -p "Enter private key (or 'save' to finish): " privateKey
    [ "$privateKey" == "save" ] && break
    privateKey=${privateKey#0x}
    [[ ! "$privateKey" =~ ^[a-fA-F0-9]{64}$ ]] && { echo "Invalid key"; continue; }
    privateKey="0x$privateKey"
    walletAddress=$(node -e "console.log(new (require('ethers')).Wallet('$privateKey').address)" 2>/dev/null) || { echo "Invalid key"; continue; }
    jq ". += [{\"address\":\"$walletAddress\",\"privateKey\":\"$privateKey\"}]" wallets.json > tmp.json && mv tmp.json wallets.json
    echo "Wallet $walletAddress saved."
  done
}

convert_recipients_to_json() {
  [ ! -f recipients.txt ] && { echo "recipients.txt missing"; exit 1; }
  jq -R -s -c 'split("\n")[:-1]' recipients.txt > recipients.json
}

create_transaction_amount() {
  read -p "Enter amount per transaction (TEA): " amount
  echo "TRANSACTION_AMOUNT=$amount" >> .env
}

create_bot_js() {
  cat > bot.js <<'EOL'
const axios = require('axios'), cron = require('node-cron'), fs = require('fs'), { ethers } = require('ethers');
require('dotenv').config();

const provider = new ethers.JsonRpcProvider(process.env.TEA_RPC_URL);
const wallets = JSON.parse(fs.readFileSync('wallets.json'));
const recipients = JSON.parse(fs.readFileSync('recipients.json'));
const amount = ethers.parseUnits(process.env.TRANSACTION_AMOUNT, 18);

const getGasPrice = async () => {
  try {
    const { data } = await axios.get('https://sepolia.tea.xyz/gas-tracker');
    const gasPriceGwei = parseFloat(data.fast) * 1.2;
    return ethers.parseUnits(gasPriceGwei.toFixed(2), 'gwei');
  } catch {
    const fee = await provider.getFeeData();
    return fee.gasPrice * 120n / 100n;
  }
};

const getTotalTxCount = async (address) => {
  try {
    const { data } = await axios.get(`https://sepolia.tea.xyz/api?module=account&action=txlist&address=${address}`);
    return data.result.length;
  } catch {
    return 'N/A';
  }
};

const sendTx = async (wallet, recipient, retries = 3) => {
  const signer = new ethers.Wallet(wallet.privateKey, provider);
  let status = 'Failed', txHash = 'N/A';
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const balance = await provider.getBalance(wallet.address);
      if (balance < amount) throw new Error('Insufficient balance');
      const gasPrice = await getGasPrice();
      const nonce = await provider.getTransactionCount(wallet.address, 'latest');
      const tx = await signer.sendTransaction({ to: recipient, value: amount, gasPrice, gasLimit: 21000, nonce });
      txHash = tx.hash;
      await tx.wait();
      status = 'OK';
      break;
    } catch (e) {
      console.error(`Attempt ${attempt} failed: ${e.message}`);
      if (attempt === retries) status = 'Failed';
      else await new Promise(r => setTimeout(r, attempt * 5000));
    }
  }
  const totalTx = await getTotalTxCount(wallet.address);
  console.log("++++++++++++");
  console.log(`Wallet : ${wallet.address}`);
  console.log(`transactions : ${status}`);
  console.log(`tx : ${txHash}`);
  console.log(`total transactions : ${totalTx}`);
  console.log("++++++++++++");
};

cron.schedule('* * * * *', () => {
  wallets.forEach((wallet, i) => {
    const recipient = recipients[i % recipients.length];
    sendTx(wallet, recipient);
  });
});

console.log("Bot started. Transactions will run every minute.");
EOL
}

run_bot_in_foreground() {
  node bot.js
}

# Main execution
display_welcome_message
echo "Installing Node.js, jq, and dependencies... (please wait)"
install_nodejs
install_jq
install_dependencies
echo "Installation complete!"
create_env_file
create_wallets_file
convert_recipients_to_json
create_transaction_amount
create_bot_js
run_bot_in_foreground
