# NostalgiaForInfinity Updater
Bash script to update the NostalgiaForInfinity strategy and config files for freqtrade trading bot(s).

## Setup Instructions

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/NostalgiaForInfinityUpdater.git
    ```
2. Copy the .env.template file to a new file named .env in the root of the project:
    ```bash
    cp .env.template .env
    ```
3. Fill in the .env file with your specific configurations (e.g., tokens, directory paths).
4. Make the script executable:
    ```bash
    sudo chmod +x update.sh
    ```
5. Run the script with either "latest" or "tags" as a parameter, depending on your needs:
    ```bash
    ./update.sh latest
    ```
    or
    ```bash
    ./update.sh tags
    ```
6. To update automatically, add the following line to your crontab (this example runs the script every 30 minutes):
    ```bash
    sudo crontab -e
    ```
    Add the following line in the crontab file:
    ```bash
    */30 * * * * /bin/bash -c "/absolute/path/to/nfi-updater.sh latest"
    ```
    Note: Replace /absolute/path/to/nfi-updater.sh with the actual path to the script.