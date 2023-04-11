import json
import sys
import urllib3
import boto3
from datetime import datetime
import time
import re

ssm_client = boto3.client('ssm')
http = urllib3.PoolManager()

encoded_body = json.dumps({
    "vendorID": 4,
    "expiryDate": "2030-12-12",
    "title": "Hello Fresh",
    "description": "Free Meal",
    "quantity": 5,
    "isMultiuse": 0,
})

def lambda_handler(event, context):
    
    print(event)
    
    queryParams = event['queryStringParameters']
    print(queryParams)
    
    ec2_address = "http://3.129.250.41:"
    default_port = "8000"
    ProcLeader = ""
    
    stored_leader = ssm_client.get_parameter(Name='/primaryreplica/parameters/leader', WithDecryption=True)
    
    print('Attempting execution request on last stored primary replica: ' + stored_leader['Parameter']['Value'])
    try:
        # TODO: write code...
        response = http.request("GET", stored_leader['Parameter']['Value'] + "/proc/leader/")
        jsonResponse = json.loads(response.data.decode('utf-8'))
        if jsonResponse['is_leader'] is True:
            ProcLeader = stored_leader['Parameter']['Value']
        
        elif jsonResponse['is_leader'] is False:
            ssm_client.put_parameter(Name='/primaryreplica/parameters/leader', Overwrite=True, Value=jsonResponse['leader_host'],)
            new_leader = ssm_client.get_parameter(Name='/primaryreplica/parameters/leader', WithDecryption=True)
            ProcLeader = new_leader['Parameter']['Value']
            
    except urllib3.exceptions.HTTPError as e:
        print(e)
        #print('CONNECTION ERROR HAPPENED')
        for index in range(8000,8004):

            try:
                # TODO: write code...
                post_response = http.request("POST", ec2_address + str(index) + "/proc/leader/")
                if post_response.status == 200:
                    postJsonResponse = json.loads(post_response.data.decode('utf-8'))
                    ssm_client.put_parameter(Name='/primaryreplica/parameters/leader', Overwrite=True, Value=postJsonResponse['leader_host'],)
                    new_leader = ssm_client.get_parameter(Name='/primaryreplica/parameters/leader', WithDecryption=True)
                    ProcLeader = new_leader['Parameter']['Value']
                    break
            except urllib3.exceptions.HTTPError as e:
                print(e)
                pass
        if len(ProcLeader) == 0:
            print('ALL SERVERS ARE DOWN!')
        pass
    
    print('Executing request on primary leader server: ' + ProcLeader)
    
    data = {
        "vendorID": queryParams['vendorID'],
        "expiryDate": queryParams['expiryDate'],
        "title": queryParams['title'],
        "description": queryParams['description'],
        "quantity": queryParams['quantity'],
        "isMultiuse": queryParams['isMultiuse']
    }
     
    encoded_data = json.dumps(data).encode('utf-8')
    
    # if queryParams is None:
    #     query = querySelect
    response = http.request("POST", ProcLeader + f"/coupons/?vendorID={data['vendorID']}&expiryDate={data['expiryDate']}&title={data['title']}&description={data['description']}&quantity={data['quantity']}&isMultiuse={data['isMultiuse']}", headers={'Content-Type': 'application/json'}, body=encoded_data)
    txn_ts = re.search("(\d{4}[-]?\d{1,2}[-]?\d{1,2} \d{1,2}:\d{1,2}:\d{1,2})", str(datetime.fromtimestamp(time.time())))
    # print(txn_ts)

    print('HEARTBEAT CHECK')
    try:
        print((http.request("GET", "http://3.129.250.41:8000/")).status)
        print('REPLICA 1 ALIVE')
        ssm_client.put_parameter(Name='/instance-1/last-executed-query', Overwrite=True, Value=txn_ts.group(),)
    except urllib3.exceptions.HTTPError as e:
        print(e)
        if(e): 
            print('REPLICA 1 DOWN')
    try:
        print((http.request("GET", "http://3.129.250.41:8001/")).status)
        print('REPLICA 2 ALIVE')
        ssm_client.put_parameter(Name='/instance-2/last-executed-query', Overwrite=True, Value=txn_ts.group(),)
    except urllib3.exceptions.HTTPError as e:
        print(e)
        if(e): 
            print('REPLICA 2 DOWN')
    try:
        print((http.request("GET", "http://3.129.250.41:8002/")).status)
        print('REPLICA 3 ALIVE')
        ssm_client.put_parameter(Name='/instance-3/last-executed-query', Overwrite=True, Value=txn_ts.group(),)
    except urllib3.exceptions.HTTPError as e:
        print(e)
        if(e): 
            print('REPLICA 3 DOWN')
    try:
        print((http.request("GET", "http://3.129.250.41:8003/")).status)
        print('REPLICA 4 ALIVE')
        ssm_client.put_parameter(Name='/instance-4/last-executed-query', Overwrite=True, Value=txn_ts.group(),)
    except urllib3.exceptions.HTTPError as e:
        print(e)
        if(e): 
            print('REPLICA 4 DOWN')
    
    print(response.data.decode('utf-8'))
    #response = http.request("POST", "http://3.144.123.146:8000/coupons/")
    # TODO implement
    return {
        'statusCode': 200,
        'body': response.data.decode('utf-8')
    }
    
    
