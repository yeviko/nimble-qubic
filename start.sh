#!/bin/bash

source ~/.profile

echo "Installing required libraries: python3-pip python3-venv tmux nano git"
apt update && apt install -y --no-install-recommends python3-pip python3-venv tmux nano git

echo ''  # for spacing

if [ -z "$NIMBLE_WALLET_ADDRESS" ]; then
    echo "ERROR: Cannot start nimble miner due to missing environment variables."
else
    echo '-- SETTING UP THE NIMBLE MINER --'
    echo "Preparing Nimble miner with the following settings:"
    echo "NIMBLE_MINER_ID: $NIMBLE_MINER_ID"
    echo "NIMBLE_WALLET_ADDRESS: $NIMBLE_WALLET_ADDRESS"
    echo ''
    echo 'If something is not right, press Ctrl+C to abort.'
    sleep 5
    touch "miner-$NIMBLE_MINER_ID-wallet-$NIMBLE_WALLET_ADDRESS.txt" 
    
    WORKDIR=~/nimble
    mkdir -p $WORKDIR
    cd $WORKDIR
    
    # Download the script
    echo "Downloading NIMBLE client and installing the dependencies from requirements.txt."
    git clone https://github.com/nimble-technology/nimble-miner-public.git
    cd nimble-miner-public
    
    # Not required but to be sure there's no typo (> vs >>)
    rm requirements.txt
    touch requirements.txt
    
    echo '
requests==2.31.0
torch==2.2.1
accelerate==0.27.0
transformers==4.38.1
datasets
numpy
gitpython==3.1.42' > requirements.txt

    make install
    echo "Starting Nimble Miner session. Use 'tmux a -t nimble' to view the output."
    tmux new-session -d -s "nimble" "make run addr=${NIMBLE_WALLET_ADDRESS}" || echo 'ERROR: nimble session not started'
fi


if [ -z "$QUBIC_THREADS" ] || [ -z "$QUBIC_ACCESS_TOKEN" ]; then
    echo "ERROR: Cannot start QUBIC miner due to missing environment variables."
else
    echo '-- SETTING UP THE QUBIC MINER --'
    sleep 3
    
    WORKDIR=~/qubic
    mkdir -p $WORKDIR
    cd $WORKDIR
    
    # Download the script
    echo "Downloading and unzipping the QUBIC client."
    wget https://dl.qubic.li/downloads/qli-Client-1.9.6-Linux-x64.tar.gz
    tar -xvf qli-Client-1.9.6-Linux-x64.tar.gz
    rm qli-Client-1.9.6-Linux-x64.tar.gz
    
    # Not required but to be sure there's no typo (> vs >>)
    rm appsettings.json
    touch appsettings.json

    echo '{"Settings": {"baseUrl": "https://mine.qubic.li/", "amountOfThreads": '$QUBIC_THREADS', "accessToken": "'$QUBIC_ACCESS_TOKEN'", "alias": 
"nimble-miner-'$NIMBLE_MINER_ID'"}}' > appsettings.json
    echo ''
    echo "-- Preparing Qubic miner with the following settings --"
    cat appsettings.json
    echo ''
    echo 'If something is not right, press Ctrl+C to abort.'
    sleep 5
    
    tmux new-session -d -s "qubic" "$WORKDIR/qli-Client" || echo 'ERROR: qubic session not started'
    tmux ls
    
fi

echo "Waiting a few seconds to let tmux sessions to start (or fail)..."
sleep 5

echo 'Current TMUX sessions:'
tmux ls

echo 'Use "tmux a -t SessionName" to view the output, e.g. tmux a -t nimble'

