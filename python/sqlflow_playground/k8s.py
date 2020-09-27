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

import subprocess
import time
import re

mysql_pod_config = """
apiVersion: v1
kind: Pod
metadata:
  name: sqlflow-mysql-%s
spec:
  containers:
  - name: mysql
    image: sqlflow/sqlflow:mysql
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 3306
      protocol: TCP
    env:
    - name: MYSQL_HOST
      value: "0.0.0.0"
    - name: MYSQL_PORT
      value: "3306"
    readinessProbe:
      exec:
        command:
        - cat
        - /work/mysql-inited
      initialDelaySeconds: 1
      periodSeconds: 1
"""


def is_pod_alive(name):
    cmd = ('''kubectl get pod %s '''
           '''-o jsonpath="{.status.containerStatuses'''
           '''[?(@.name=='mysql')].ready}"''') % name
    status = subprocess.getoutput(cmd)
    return status == "true"


def create_mysql_pod_for_user(user):
    user_pod_name = "sqlflow-mysql-%s" % user
    if not is_pod_alive(user_pod_name):
        config = mysql_pod_config % user
        cmd = "kubectl create -f -"
        subprocess.run(cmd, shell=True, input=config.encode("utf8"))
        for _ in range(10):
            if not is_pod_alive(user_pod_name):
                time.sleep(1)
    return get_mysql_service_addr(user_pod_name)


def get_mysql_service_addr(pod_name):
    cmd = '''kubectl get pod %s -o jsonpath="{.status.podIP}"''' % pod_name
    for _ in range(10):
        ip = subprocess.getoutput(cmd)
        if ip.count(".") == 3:
            return "mysql://root:root@tcp(%s:3306)/?maxAllowedPacket=0" % ip
        time.sleep(1)
