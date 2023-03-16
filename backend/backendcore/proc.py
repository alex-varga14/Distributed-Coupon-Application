import os
import requests
from backendcore import utils
from requests.exceptions import *

from django.conf import settings

leader_endpoint = "/proc/leader"

leader_host = ""
leader_id = -1

def elect_leader(current_port, hosts=[]):
    """
    perform leader election.

    cases:
        len(hosts) == 0: start new leader election
        len(hosts) == 1: listed server is leader
        len(hosts) >= 2: elect between those hosts
    """

    print("\n\n**********Begin leader election**********")

    global leader_host, leader_id
    leader_host = ""
    leader_id = -1

    # fresh leader election start
    if len(hosts) == 0:
        hosts = settings.REPLICAS

    print(f"Candidates: {hosts}")
    # get all hosts that aren't itself
    hosts = list(filter(
        lambda host: f":{current_port}" not in host,
        hosts))

    pid = os.getpid()

    def req_leader(host):
        """
        Asks a host if the current process
        can become leader

        if the process cannot run as leader, it returns True so that
        it can keep a list of potential leaders and tell them to initate
        an election.

        returns True if NO, False if fail or YES
        """
        try:
            req = requests.get(
                f"{host}{leader_endpoint}/{pid}",
                timeout=1
            )

            json = req.json()

            # a proc said NO
            if json["leader_result"] == False:
                print(f" - {host} says NO")
                return True

            print(f" - {host} says YES")

        except (ConnectionError, Timeout):
            print(f" - {host} is dead. X_x")
            return False

        return False

    # get hosts that have a higher pid
    # (the hosts that said NO)
    print("Asking other replicas for permission to become leader...")
    hosts = list(filter(req_leader, hosts))

    if len(hosts) == 0: # we are a leader
        print("Leader!")
        leader_id = os.getpid()
        leader_host = f"http://localhost:{current_port}"

    else: # we are not a leader
        print("Not a leader!")
        nextHost = hosts[0]

        print(f"Requesting {nextHost} to perform leader election")

        # need string as base64
        hostsStr = ",".join(hosts)
        b64 = utils.toBase64(hostsStr)
        urlStr = requests.utils.quote(b64)

        url = f"{nextHost}{leader_endpoint}/?hosts={urlStr}"
        r = requests.get(url).json()

        leader_id = r["pid"]
        leader_host = r["leader_host"]

        print(f"Got leader! host={leader_host}, pid={leader_id}")

    print("**********End leader election**********\n\n")

    return (leader_id, leader_host)

# checks if it is a leader. if no leader is assigned, it will begin
# leader election
def is_leader(current_port):
    if leader_id == -1:
        elect_leader(current_port)

    return leader_id == os.getpid()

def get_leader(current_port):
    if leader_id == -1:
        elect_leader(current_port)
    return leader_host

def is_remote_pid_higher(remote_pid):
    local_pid = os.getpid()
    return remote_pid > local_pid



