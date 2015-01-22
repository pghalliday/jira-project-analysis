jira-time-series
================

Capturing and querying JIRA time series data

Notes
=====


- For development you will want the GID and UID for the `jts` user to match the user you are using on the host (so that files created/modified by npm/gulp inside the container are still owned by you). To achieve this run the following script before building the containers with fig, etc (don't do this for containers you wish to distribute)

    ```
    ./docker-scripts/generate-dev-overrides.sh
    ```

- Use `fig up` to start docker containers in development mode
  - mounts local directory
  - starts server
  - watches for changes to source code
- Use `./run.sh` to run other commands on the container, eg.
  - `./run.sh gulp test`
  - `./run.sh npm install --save blah-blah`
