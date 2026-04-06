#!/bin/bash
set -e

# This script is executed as root by default.



CONTAINER_PROJECT_PATH="${PWD}"
LOGFILE="${CONTAINER_PROJECT_PATH}"/on-create.log
echo "Executing post-creation script..."
# 2. Run the original Python environment setup
# pipx install uv && uv venv --allow-existing && uv sync

# 1. Restore Gemini credentials if they exist
{
    # CRED_SOURCE_DIR="${CONTAINER_PROJECT_PATH}/.devcontainer/.persisted-credentials"
    CRED_SOURCE_DIR="${CONTAINER_PROJECT_PATH}/.devcontainer/.home"
    # CRED_SOURCE_FILE="${CRED_SOURCE_DIR}/"*.json
    CRED_DEST_DIR="${HOME}"
    # CRED_DEST_PATH="${HOME}/.gemini"
    # CRED_DEST_FILE="${CRED_DEST_DIR}/"*.json

    echo -e "checking for: \n${CRED_SOURCE_DIR}\n..."
    if [ -d $CRED_SOURCE_DIR ]; then
        echo "Restoring Gemini credentials..."
        shopt -s dotglob  # Turn it on
        cp -r "${CRED_SOURCE_DIR}"/* "${CRED_DEST_DIR}"
        shopt -u dotglob  # Turn it off (good practice)
        
        # echo "Creating credential dest dir ${CRED_DEST_DIT}..."
        # mkdir -p "$CRED_DEST_DIR"
        # echo "copying ${CRED_SOURCE_DIR} to ${CRED_DEST_DIR}..."
        # cp -r ${CRED_SOURCE_DIR} "${CRED_DEST_DIR}"
        # Ensure the 'vscode' user owns the restored files, not root
        # echo "chowing -R ${CRED_DEST_DIR}"
        # chown -R vscode:vscode "${CRED_DEST_DIR}"
        # echo "Showing ${CRED_DEST_DIR}..."
        # ls -la "${CRED_DEST_PATH}"
        echo "Credentials restored and permissions set."
    else
        echo -e "ERROR | cannot find \n${CRED_SOURCE_DIR}\n cannot login into gemini"
        read -p "press ENTER"
    fi
} 2>&1 | tee "${LOGFILE}"

ALIASES_PATH="${CONTAINER_PROJECT_PATH}/.devcontainer/.aliases"
BASHRC_PATH="${HOME}/.bashrc"
echo "checking for ${ALIASES_PATH}..."
if [ -f "${ALIASES_PATH}" ]
then
    echo "adding source ${ALIASES_PATH} to ${BASHRC_PATH}..."
    echo "source ${ALIASES_PATH}" >> "${BASHRC_PATH}"
    echo "done"
else
    echo "ERROR | cannot find ${ALIASES_PATH}, cannot souurce aliases"
fi

# 1. Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "1. Installing uv via pipx..."
    pipx install uv
fi

# 2. Sync the environment
echo "2. Syncing Python environment with uv..."
# This will look for a pyproject.toml in your workspace
uv sync
