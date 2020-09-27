# SQLFlow Playground Server

SQLFlow Playground Server expose an REST API service which enable users to share
the resources in one playground cluser. Users can use the capability of SQLFlow
by installing a small plugin on her/his own Jupyter Notebook.

## For Service Maintainer
The maintainer should [provide the playground cluster](../dev.md), and
bootup a `SQLFlow Playground Server`.  The server should have privillege
to access the `kubectl` command of the cluster.  To install the server,
maintainer can use below command:
```bash
    mkdir $HOME/workspace
    cd $HOME/workspace
    pip install sqlflow_playground
    mkdir key_store
    gen_cert.sh server
    sqlflow_playground --port=50052 \
      --ca_crt=key_store/ca/ca.crt \
      --server_key=key_store/server/server.key \
      --server_crt=key_store/server/server.crt
```
In above commands, we first installed the sqlflow playground package
which carries the main cluster operation logic.  Then, we use the key
tool to generate a server certification file (Of course, it's not necessary
if you have your own certification files) which enable use to provide
`https` service.  Finally, we start the `REST API` service at port 50052.

Our playground service use bi-directional validation.  So, maintainer need
to generate a certification file for trusted user. Use below command and
send the generated `.crt` and `.key` file to the user.
```bash
    gen_cert.sh some_client
```

## For Users
To use this service, user should get authorized from the playround's maintainer.
In detail, user should get `ca.crt`, `client.key` and the `client.crt` file from
ther maintainer and keep them in some very-safe place. Also the user should ask
the maintainer for the sqlflow server address and the sqlflow playground server
address. Then, user will install jupyter notebook and the SQLFlow plugin package
and do some configuration. Finally, the user can experience SQLFlow in his jupyter notebook.

```bash
    pip3 install notebook sqlflow==0.15.0

    cat >$HOME/.sqlflow_playground.env <<EOF
SQLFLOW_SERVER="{sqlflow server address}"
SQLFLOW_PLAYGROUND_USER_ID_ENV=SQLFLOW_USER_ID
SQLFLOW_USER_ID="{your name}"
SQLFLOW_PLAYGROUND_SERVRE="{sqlflow playground server address}"
SQLFLOW_PLAYGROUND_SERVER_CA="{path to your ca.crt file}"
SQLFLOW_PLAYGROUND_CLIENT_KEY="{path to your client.key file}"
SQLFLOW_PLAYGROUND_CLIENT_CERT="{path to your client.crt file}"
EOF

    export SQLFLOW_JUPYTER_ENV_PATH="$HOME/.sqlflow_playground.env"
    jupyter notebook
```
