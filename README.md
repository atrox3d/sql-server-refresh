# Setup SQL Server with docker on vscode
[sqlserver+docker](https://youtu.be/JwChEzHTuN8)

    vscode extension: ms-mssql.mssql

## Other resources for ARM/MacOS
[Development with SQL in containers on macOS](https://devblogs.microsoft.com/azure-sql/development-with-sql-in-containers-on-macos/)


## Connection settings when contaniner alreay created

Server name can point to another machine,

eg: 102.168.1.10,1433

![Alt Text](connection-settings.png)

## Retrieve forgotten password
```bash
# identify container id
docker ps

# show password
docker inspect {container_id} | grep -i password
```
---
<br>
<br>

# Tutorials/Channels/Resources


- Tutorial: [SQL Server tutorial for beginners](https://youtube.com/playlist?list=PL08903FB7ACA1C2FB)

- Channel: [The Code Samples](https://www.youtube.com/@thecodesamples)
- Channel: [Absent Data](https://www.youtube.com/@absentdata)
- Channel: [Database Star](https://www.youtube.com/@DatabaseStar)




