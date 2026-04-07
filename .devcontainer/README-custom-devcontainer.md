# devcontainer setup readme

## directory structure of .devcontainer/

| path   | purpose |tracked |
|--------|---------|--------|
|.secrets/ | keep sensible data from git |no |
|.secrets/password.txt | used by docker compose| no |
|.home/.gemini | keep gemini oauth data from git | no |
|.home/.cache/google-vscode-extension | keep gemini oauth data from git | no |
|.env | sensible data env vars | no |
|.aliases | aliases for bash | no |
|devcontainer.json | root config for devcontainer | yes |
|docker-compose.yaml | root docker compose referenced by devcontainer.json | yes |
|compose-devcontainer.yaml | devcontainer service definition | yes |
|dockerfile-devcontainer | devcontainer image definition | yes |
|compose-sqlserver.yaml | mssql_dev service definition | yes |
|on-create.sh | postCreateCommand script referenced in devcontainer.json | yes |
|refresh-gemini-credentials.sh | update the .devcontainer/.home folder content with gemini credentials | yes |

## dependency hierarchy

```text
devcontainer.json
├── docker-compose.yaml/
│   │
│   ├── compose-devcontainer.yaml/
│   │   │
│   │   └── dockerfile-devcontainer
│   │
│   └── compose-sqlserver.yaml/
│       │
│       └── .env
│
└── on-create.sh
```


## on-create.sh

the on-create.sh script is triggered automatically by devcontainer.json inside the key:

```json
{
  "postCreateCommand": ".devcontainer/on-create.sh",
}
```

it is divided in 3 main sections:

### restore gemini code assist extension login
once logged in gemini code assist the folders:

```
~/.gemini
~/.cache/google-vscode/extension
```

are created and contain the auth files.
we copy these folders manually or via the refresh-gemini-credentials.sh inside the folder:

```
.devcontainer/.home
```

every time we recreate the container this section of the script restores the two folder in the home directory.

## restore bash aliases
this section injects a line inside ~/.bashrc containing the source command:

```bash
source path/to/.devcontainer/.aliases
```

### install uv and suync venv
if needed this section installs uv and syncs the venv using the project.toml and uv.lock files
for this project its needed to run the get-csv-schema.py script

