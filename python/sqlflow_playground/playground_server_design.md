# SQLFlow Playground Server

SQLFlow Playground Server exposes a REST API service that enables users to share
the resources in one playground cluster. Users can take advantage of SQLFlow by
installing a small [plugin](https://github.com/sql-machine-learning/pysqlflow)
on her/his Jupyter Notebook.

This service is used to extend the SQLFlow Playground's capability, especially
when we need to manage the resource in the k8s cluster. We suppose the playground
as a pure backend service (without Jupyter/JupyterHub) which provides machine 
learning capability for some frontend. It clearly is not for those who just want
to connect to the SQLFlow server in the playground through our built-in Jupyter 
Notebook. Currently, this service is used to run our tutorials on [Aliyun
DSW for Developer](https://dsw-dev.data.aliyun.com/) which behaves as a frontend
of our playground.

## The Architecture

**SQLFlow Playground Server** is a side-car service of our playground cluster.
Now, it is designed as an HTTP server which receives user login, creates DB
resource, and so on. This server uses `kubectl` to manipulate the resource in
the playground(a k8s cluster). It's in someway the gateway of the playground.
As described in the below diagram, the interaction of the three subjects could
be: Clients ask the playground server for some resource. The server authorizes
the client and create the resource on the playground. The client connects to
the SQLFlow server in the playground and does train/predict tasks using the
created resource.

```
   ----------------run task--------------------------->
   |                                                  |
Clients <--> Playground Server <--> Playground[SQLFlow Server, MySQL Server...]
```

## Supported API

Request URL path is composed by the prefix `/api/` and the api name, like:

```url
    https://playground.sqlflow.tech/api/heart_beat
```
This service always uses `HTTPS` and only accepts authorized clients
by checking their certification file. So there is no dedicated api
for user authentication.

Currently supported API are:
| name | method | params | description |
| - | - | - | - |
| create_db | POST | {"user_id": "id"} | create a DB for given user, json param |
| heart_beat| GET  | user_id=id | report a heart beat of given client |


## How to Use

### For Service Maintainer
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
In the above commands, we first installed the sqlflow playground package
which carries the main cluster operation logic.  Then, we use the key
tool to generate a server certification file (Of course, it's not necessary
if you have your own certification files) which enables us to provide
`HTTPS` service.  Finally, we start the `REST API` service at port 50052.

Our playground service uses bi-directional validation.  So, the maintainer
needs to generate a certification file for a trusted user. Use below command and
send the generated `.crt` and `.key` file together with the `ca.crt` to
the user.

```bash
    gen_cert.sh some_client
```

### For The User

To use this service, the user should get authorized from the playground's maintainer.
In detail, user should get `ca.crt`, `client.key` and the `client.crt` file from
the maintainer and keep them in some very-safe place. Also, the user should ask
the maintainer for the sqlflow server address and the sqlflow playground server
address. Then, the user will install Jupyter Notebook and the SQLFlow plugin package
and do some configuration. Finally, the user can experience SQLFlow in his Jupyter 
Notebook.

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
    # start the notebook and try use %%sqlflow magic command
    jupyter notebook
```

## Implementation

We use [tornado](https://www.tornadoweb.org/) as the web framework which provides
a very good request dispatching mechanism. By the way, this framework is also
adopted by Jupyter Notebook. The request processing is split into two steps:

1. Register a request handler

    ```python
    tornado.web.Application([(r"/", MainHandler)])
    ```
1. Implement the handler as a class, the method name `get` imply
    it accepts `GET` requests.

    ```python
    class MainHandler(RequestHandler):
        def get(self):
           self.write("hello SQLFlow!") 
    ```
In addition, We add a k8s manipulate class, which can create resource in the
cluster. It's now implemented in a brutal way (use kubectl). We may refine it
by using k8s's API.
