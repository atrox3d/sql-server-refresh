# Tutorials/Channels/Resources


- Channel: [kudvenkat](https://www.youtube.com/@Csharp-video-tutorialsBlogspot)
    - Tutorial: [SQL Server tutorial for beginners](https://youtube.com/playlist?list=PL08903FB7ACA1C2FB)

- Channel: [The Code Samples](https://www.youtube.com/@thecodesamples)
- Channel: [Absent Data](https://www.youtube.com/@absentdata)
- Channel: [Database Star](https://www.youtube.com/@DatabaseStar)
<br>
<br>
<br>

# Docker/Devcontainer Setup

- basic ephemeral mssql container provided by the extension itself [Default mssql extension container](./.devcontainer/README-default-docker.md)
no I/O possible, nopersistence guaranteed
<br/>

- to enable csv import and map local FS to docker container its is possible to create a [Custom devcontainer](./.devcontainer/README-custom-devcontainer.md)


## Workspace structure

```text
.devcontainer
├── .home/
│   │
│   ├── .cache/
│   │   │
│   │   └── google-vscode-exension
│   │
│   └── .gemini/
│
├── .msssql_data/
│
├── 0-data/
│   │
│   ├── ${tutorial-name}/
│   ...
│
└── ${tutorial-name}
│
└── ...
```

