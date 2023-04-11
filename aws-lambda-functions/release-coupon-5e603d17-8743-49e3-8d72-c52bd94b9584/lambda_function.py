import json
import sys
import urllib3
import boto3

ssm_client = boto3.client('ssm')
http = urllib3.PoolManager()

def lambda_handler(event, context):
    
    ec2_address = "http://3.129.250.41:"
    ProcLeader = ""
    stored_leader = ssm_client.get_parameter(Name='/primaryreplica/parameters/leader', WithDecryption=True)
    
    print('Attempting execution request on last stored primary replica: ' + stored_leader['Parameter']['Value'])
    try:
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
    
    #response = http.request("POST", ProcLeader + f"/vendors/?country={data['country']}&city={data['city']}&name={data['vendorName']}", headers={'Content-Type': 'application/json'}, body=encoded_data)
    response = http.request("GET", ProcLeader + "/coupons/release/13/")
    print(response.data.decode('utf'))

    return {
    }
