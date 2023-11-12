#!/bin/bash

# Load environment variables
source .env

# Check if the mode argument is provided
if [ -z "$1" ]; then
    echo "No mode specified. Use 'latest' or 'tags'."
    exit 1
fi

MODE=$1

# Function to copy strategy and config files
copy_files() {
    cp "${NFI_DIR}/${STRATEGY}" "$1/strategies"
    cp "${NFI_DIR}/configs/$2" "$1"
    cp "${NFI_DIR}/configs/$3" "$1"
}

# Go to NFI directory
cd "$NFI_DIR" || exit

if [ "$MODE" == "tags" ]; then
    # Fetch latest tags
    git fetch --tags
    
    # Get tags names
    latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
    current_tag=$(git describe --tags)
    
    # Check if new tag is available
    if [ "$latest_tag" != "$current_tag" ]; then
        # Checkout to latest tag and update the NFI in Freqtrade folder
        git checkout tags/$latest_tag -b $latest_tag || git checkout $latest_tag 

        # Call function to copy files
        copy_files "$FT_ALPHA_DIR" "$FT_ALPHA_PAIRLIST" "$FT_ALPHA_BLACKLIST"
        copy_files "$FT_BETA_DIR" "$FT_BETA_PAIRLIST" "$FT_BETA_BLACKLIST"

        # Get tag to which the latest tag is pointing
        latest_tag_commit=$(git rev-list -n 1 tags/${latest_tag})
    
        # Compose and send the message
        message="NFI is updated to tag: *${latest_tag}*"
        keyboard="{\"inline_keyboard\":[[{\"text\":\"Changes\", \"url\":\"${GIT_URL}/compare/${current_tag}...${latest_tag}\"},{\"text\":\"Backtesting\", \"url\":\"${GIT_URL}/commit/${latest_tag_commit}\"}]]}"
        curl -s --data "text=${message}" --data "reply_markup=${keyboard}" --data "chat_id=$TG_CHAT_ID" --data "parse_mode=markdown" "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
    fi

elif [ "$MODE" == "latest" ]; then
    # Get current commit
    current_commit=$(git rev-parse --short HEAD)

    # Pull latest changes
    git checkout main
    git pull origin main
    
    # Get latest commit
    latest_commit=$(git rev-parse --short HEAD)

    if [ "$latest_commit" != "$current_commit" ]; then
        # Call function to copy files
        copy_files "$FT_ALPHA_DIR" "$FT_ALPHA_PAIRLIST" "$FT_ALPHA_BLACKLIST"
        copy_files "$FT_BETA_DIR" "$FT_BETA_PAIRLIST" "$FT_BETA_BLACKLIST"

        # Compose and send the message
        message="NFI is updated to commit: *${latest_commit}*"
        keyboard="{\"inline_keyboard\":[[{\"text\":\"Changes\", \"url\":\"${GIT_URL}/commit/${latest_commit}\"}]]}"
        curl -s --data "text=${message}" --data "reply_markup=${keyboard}" --data "chat_id=$TG_CHAT_ID" --data "parse_mode=markdown" "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
    fi
else
    echo "Unsupported mode: $MODE. Supported modes are 'tags' and 'latest'."
    exit 1
fi
