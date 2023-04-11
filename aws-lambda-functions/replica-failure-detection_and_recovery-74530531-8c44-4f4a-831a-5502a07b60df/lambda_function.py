import json
import mysql.connector
from mysql.connector import Error
import sys
import urllib3
import boto3
import re
from datetime import datetime
import time

ssm_client = boto3.client('ssm')
http = urllib3.PoolManager()

def synchronize_databases(primary_db, replica_db):
    try:
        # Connect to primary database
        primary_conn = mysql.connector.connect(
            host=primary_db['host'],
            port=primary_db['port'],
            user=primary_db['user'],
            password=primary_db['password'],
            database=primary_db['database']
        )

        # Connect to replica database
        replica_conn = mysql.connector.connect(
            host=replica_db['host'],
            port=replica_db['port'],
            user=replica_db['user'],
            password=replica_db['password'],
            database=replica_db['database']
        )

        # Get primary database cursor
        primary_cursor = primary_conn.cursor()
        primary_cursor.execute("SHOW TABLES")
        tables = [table[0] for table in primary_cursor]
        primary_cursor.close()
        
        
        for table in tables:
            if table == "backendcore_coupon" or table == "backendcore_vendor":
                print(f"Cloning Table {table}")
                primary_cursor = primary_conn.cursor()
                primary_cursor.execute(f"SELECT * FROM cpsc559.{table}")
                data = primary_cursor.fetchall()
                # for d in data:
                #     print(d)
                primary_cursor.close()
                
                replica_cursor = replica_conn.cursor()
                try:
                    print('CLONING')
                    replica_cursor.execute("START TRANSACTION")
                    replica_cursor.execute(f"DELETE FROM cpsc559.{table}")
                    replica_cursor.executemany(f"INSERT INTO cpsc559.{table} VALUES ({', '.join(['%s']*len(data[0]))})", data)
                    replica_cursor.execute("COMMIT")
                except:
                    replica_cursor.execute("ROLLBACK")
                    print('CLONING ROLLBACKED')
                    raise
                finally:
                    replica_cursor.close()
        
        replica_conn.close()
        primary_conn.close()

    except Error as e:
        print(e)
        
def get_last_synced_time(cursor):
    #cursor.execute("SELECT value FROM parameter_store WHERE name='last_synced_time'")
    #result = cursor.fetchone()
    result = ssm_client.get_parameter(Name='/instance-1/last-executed-query', WithDecryption=True)
    return result['Parameter']['Value']
    # if result:
    #     return result[0]
    # else:
    #     return '1970-01-01 00:00:00'  # default value if parameter store entry doesn't exist

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
    
    primary_db = {}
    primary_db['host'] = "3.129.250.41"
    primary_db['port'] = "500"+ ProcLeader[-1:]
    print('Port is '+ primary_db['port'])
    primary_db['user'] = "root"
    primary_db['password'] = "coupons1001"
    primary_db['database'] = "cpsc559"
    
    i1 = False
    i2 = False
    i3 = False
    i4 = False
    
    if ProcLeader[-1:] == "0":
        param = ssm_client.get_parameter(Name='/instance-1/last-executed-query', WithDecryption=True)
        i1 = True
    elif ProcLeader[-1:] == "1":
        param = ssm_client.get_parameter(Name='/instance-2/last-executed-query', WithDecryption=True)
        i2 = True
    elif ProcLeader[-1:] == "3":
        param = ssm_client.get_parameter(Name='/instance-3/last-executed-query', WithDecryption=True)
        i3 = True
    elif ProcLeader[-1:] == "4":
        param = ssm_client.get_parameter(Name='/instance-4/last-executed-query', WithDecryption=True)
        i4 = True
        
    print('PARAM ' + param['Parameter']['Value'])
    #primary-last-executed = param['Parameter']['Value']
    
    if i1 is False and param['Parameter']['Value'] is not ssm_client.get_parameter(Name='/instance-1/last-executed-query', WithDecryption=True)['Parameter']['Value']:
        print('SYNC ON REPLICA 1')
        replica1_db = {}
        replica1_db['host'] = "3.129.250.41"
        replica1_db['port'] = "5000"
        replica1_db['user'] = "root"
        replica1_db['password'] = "coupons1001"
        replica1_db['database'] = "cpsc559"
        synchronize_databases(primary_db, replica1_db)
        ssm_client.put_parameter(Name='/instance-1/last-executed-query', Overwrite=True, Value=param['Parameter']['Value'],)
        
    if i2 is False and param['Parameter']['Value'] != ssm_client.get_parameter(Name='/instance-2/last-executed-query', WithDecryption=True)['Parameter']['Value']:
        print('SYNC ON REPLICA 2')
        replica2_db = {}
        replica2_db['host'] = "3.129.250.41"
        replica2_db['port'] = "5001"
        replica2_db['user'] = "root"
        replica2_db['password'] = "coupons1001"
        replica2_db['database'] = "cpsc559"
        synchronize_databases(primary_db, replica2_db)
        ssm_client.put_parameter(Name='/instance-2/last-executed-query', Overwrite=True, Value=param['Parameter']['Value'],)
    
    if i3 is False and param['Parameter']['Value'] != ssm_client.get_parameter(Name='/instance-3/last-executed-query', WithDecryption=True)['Parameter']['Value']:
        print('SYNC ON REPLICA 3')
        replica3_db = {}
        replica3_db['host'] = "3.129.250.41"
        replica3_db['port'] = "5002"
        replica3_db['user'] = "root"
        replica3_db['password'] = "coupons1001"
        replica3_db['database'] = "cpsc559"
        synchronize_databases(primary_db, replica3_db)
        ssm_client.put_parameter(Name='/instance-3/last-executed-query', Overwrite=True, Value=param['Parameter']['Value'],)
        
    # print('PARAM 4 ' + ssm_client.get_parameter(Name='/instance-4/last-executed-query', WithDecryption=True)['Parameter']['Value'])
    # flag = False
    # if param['Parameter']['Value'] == ssm_client.get_parameter(Name='/instance-4/last-executed-query', WithDecryption=True)['Parameter']['Value']:
    #     flag = True
    #if i4 is False and flag is not True:
    if i4 is False and param['Parameter']['Value'] != ssm_client.get_parameter(Name='/instance-4/last-executed-query', WithDecryption=True)['Parameter']['Value']:
        print('SYNC ON REPLICA 4')
        replica4_db = {}
        replica4_db['host'] = "3.129.250.41"
        replica4_db['port'] = "5003"
        replica4_db['user'] = "root"
        replica4_db['password'] = "coupons1001"
        replica4_db['database'] = "cpsc559"
        synchronize_databases(primary_db, replica4_db)
        ssm_client.put_parameter(Name='/instance-4/last-executed-query', Overwrite=True, Value=param['Parameter']['Value'],)
        
    return {
    }
