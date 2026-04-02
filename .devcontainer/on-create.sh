#!/bin/bash
set -e

# This script is executed as root by default.



echo "Executing post-creation script..."
# 2. Run the original Python environment setup
# pipx install uv && uv venv --allow-existing && uv sync

# 1. Restore Gemini credentials if they exist
CONTAINER_PROJECT_PATH="${PWD}"

CRED_SOURCE_DIR="${CONTAINER_PROJECT_PATH}/.devcontainer/.persisted-credentials"
CRED_SOURCE_FILE="${CRED_SOURCE_DIR}/oauth_creds.json"
CRED_DEST_DIR="${HOME}/.gemini"
CRED_DEST_FILE="${CRED_DEST_DIR}/oauth_creds.json"
echo "checking for ${CRED_SOURCE_FILE}..."
if [ -f "$CRED_SOURCE_FILE" ]; then
    echo "Restoring Gemini credentials..."
    mkdir -p "$CRED_DEST_DIR"
    cp "$CRED_SOURCE_FILE" "$CRED_DEST_FILE"
    # Ensure the 'vscode' user owns the restored files, not root
    chown -R vscode:vscode "${HOME}/.gemini"
    echo "Credentials restored and permissions set."
else
    echo "ERROR | cannot find ${CRED_SOURCE_FILE}. cannot login into gemini"
fi


ALIASES_PATH="${CONTAINER_PROJECT_PATH}/.aliases"
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
