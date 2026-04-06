#!/bin/bash
set -e

# This script is executed as root by default.



CONTAINER_PROJECT_PATH="${PWD}"
LOGFILE="${CONTAINER_PROJECT_PATH}"/on-create.log
echo "Executing post-creation script..."

{
    echo "########################################################"
    echo "# 1. Restore Gemini credentials if they exist"
    echo "# CHECK ${LOGFILE} for details..."
    echo "########################################################"
    CRED_SOURCE_DIR="${CONTAINER_PROJECT_PATH}/.devcontainer/.home"
    CRED_DEST_DIR="${HOME}"
    
    echo "CRED_SOURCE_DIR: ${CRED_SOURCE_DIR}"
    echo "CRED_DEST_DIR. : ${CRED_DEST_DIR}"
    echo -e "checking for: \n${CRED_SOURCE_DIR}\n..."
    if [ -d $CRED_SOURCE_DIR ]; then
        echo "Restoring Gemini credentials..."
        shopt -s dotglob  # Turn it on
        cp -r "${CRED_SOURCE_DIR}"/* "${CRED_DEST_DIR}"
        shopt -u dotglob  # Turn it off (good practice)
        echo "Credentials restored and permissions set."
    else
        echo    "***********************************************************************"
        echo -e "* ERROR | cannot find \n${CRED_SOURCE_DIR}\n cannot login into gemini"
        echo    "* CHECK ${LOGFILE} for details..."
        echo    "***********************************************************************"
        read -p "* press ENTER"
    fi
} 2>&1 | tee "${LOGFILE}"

echo "########################################################"
echo "# 2. Restore aliases"
echo "########################################################"
ALIASES_PATH="${CONTAINER_PROJECT_PATH}/.devcontainer/.aliases"
BASHRC_PATH="${HOME}/.bashrc"
echo "checking for ${ALIASES_PATH}..."
if [ -f "${ALIASES_PATH}" ]
then
    echo "adding source ${ALIASES_PATH} to ${BASHRC_PATH}..."
    echo "source ${ALIASES_PATH}" >> "${BASHRC_PATH}"
    echo "done"
else
    echo "***********************************************************************"
    echo "* ERROR | cannot find ${ALIASES_PATH}, cannot souurce aliases"
    echo "***********************************************************************"
fi

echo "########################################################"
echo "# 3. Install uv if not present"
echo "########################################################"
# 1. Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "1. Installing uv via pipx..."
    pipx install uv
fi

echo "########################################################"
echo "# 2. Sync the environment"
echo "########################################################"
echo "2. Syncing Python environment with uv..."
# This will look for a pyproject.toml in your workspace
uv sync
