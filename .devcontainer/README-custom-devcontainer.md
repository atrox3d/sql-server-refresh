# devcontainer setup readme

## directory structure of .devcontainer/

| path   | purpose |tracked |
|--------|---------|--------|
|.secrets/ | keep sensible data from git |no |
|.secrets/password.txt | used by docker compose| no |
|.persisted-credentials/ | keep gemini oauth data from git | no |
|.persisted-credentials/oauth_creds.json | keep gemini oauth data from git | no |
|.env | sensible data env vars | no |
|.aliases | aliases for bash | no |
|devcontainer.json | root config for devcontainer | yes |
|docker-compose.yaml | root docker compose referenced by devcontainer.json | yes |
|compose-devcontainer.yaml | devcontainer service definition | yes |
|dockerfile-devcontainer | devcontainer image definition | yes |
|compose-sqlserver.yaml | mssql_dev service definition | yes |
|on-create.sh | postCreateCommand script referenced in devcontainer.json | yes |

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
