import os
import requests
from requests.exceptions import *

from django.conf import settings

leader_endpoint = "/proc/leader"

def elect_leader(current_port):
    hosts = list(filter(
        lambda host: f":{current_port}" not in host,
        settings.REPLICAS))

    pid = os.getpid()

    for host in hosts:
        try:
            req = requests.get(
                f"{host}{leader_endpoint}/{pid}",
                timeout=1
            )

            json = req.json()

        except (ConnectionError, Timeout):
            print(f"Host {host} is dead")

def is_remote_pid_higher(remote_pid):
    local_pid = os.getpid()
    return remote_pid > local_pid



