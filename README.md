jira-time-series
================

Capturing and querying JIRA time series data

Notes
=====

- Add a `dockerdev` group and add your current user to it so that files created within docker are editable by you without sudo

```
sudo groupadd -g 999 dockerdev
sudo usermod -a -G dockerdev $USER
```

- Use `fig up` to start docker containers in development mode
  - mounts local directory
  - starts server
  - watches for changes to source code
- Use `./run.sh` to run other commands on the containe, eg.
  - `./run.sh gulp test`
  - `./run.sh npm install --save blah-blah`
