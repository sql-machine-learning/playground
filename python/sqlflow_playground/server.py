# Copyright 2020 The SQLFlow Authors. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import json
import os
import ssl
from http import HTTPStatus
from os import path

import tornado.ioloop
import tornado.web
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.web import RequestHandler

from sqlflow_playground.k8s import create_mysql_pod_for_user


class MainHandler(RequestHandler):
    def get(self):
        self.write("Hello, SQLFlow Playground!")


class CreateUserMySQLPodHandler(RequestHandler):
    def post(self):
        params = json.loads(self.request.body)
        user_id = params["user_id"]
        if not user_id:
            self.write_error(HTTPStatus.BAD_REQUEST)
        conn_str = create_mysql_pod_for_user(user_id)
        out = {
            "data_source": conn_str
        }
        self.write(json.dumps(out))
        self.flush()


class ClientHeartBeatHandler(RequestHandler):
    def get(self):
        user_id = self.get_argument("user_id")
        # (TODO: lhw) keep track of the client's state
        print("Receive heart beat from: %s" % user_id)
        self.write("hello %s" % user_id)
        self.flush()


def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
        (r"/api/create_db", CreateUserMySQLPodHandler),
        (r'/api/heart_beat', ClientHeartBeatHandler)
    ])


parser = argparse.ArgumentParser()
parser.add_argument("--port", type=int,
                    help="Port of the service",
                    action="store",
                    default=9999)
parser.add_argument("--ca_crt", type=str,
                    help="Path to CA certificates.",
                    action="store",
                    default=None)
parser.add_argument("--server_key",
                    type=str,
                    help="Path to server key.",
                    action="store",
                    default=None)
parser.add_argument("--server_crt",
                    type=str,
                    help="Path to server crt.",
                    action="store",
                    default=None)


def main():
    """SQLFlow Playground Server

    We expect this server to be an open API service for SQLFlow Playground.

    Current, this service is used to allocate DB resource in the cluster.
    The clients will connect to this server to get DB connection string,
    and use them in later trainning/prediction. This service will keep track
    of the client, and release DB resource when the client is not active.

    """
    args = parser.parse_args()
    ssl_ctx = None
    if args.ca_crt and args.server_crt and args.server_key:
        ssl_ctx = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        ssl_ctx.load_cert_chain(args.server_crt, args.server_key)
        ssl_ctx.load_verify_locations(args.ca_crt)
        ssl_ctx.check_hostname = False
    else:
        print("SSL is not enabled.")
    app = make_app()
    server = HTTPServer(app, ssl_options=ssl_ctx)
    server.listen(args.port)
    print("Server started at %d" % args.port)
    IOLoop.current().start()


if __name__ == "__main__":
    main()
