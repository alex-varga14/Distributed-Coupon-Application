import mysql.connector
import json
import boto3

ssm_client = boto3.client('ssm', region_name='us-east-2')

def check_db_health(db_host, db_port, db_user, db_password, db_name):
    try:
        conn = mysql.connector.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            database=db_name,
            connect_timeout=10
        )
        cursor = conn.cursor(buffered=True)
        cursor.execute("SELECT 1")
        cursor.close()
        conn.close()
        return True
    except mysql.connector.Error as err:
        print(err)
        return False
    
def lambda_handler(event, context):
    
    instance1_db_status = check_db_health("3.129.250.41", "5000", "root", "coupons1001", "cpsc559")
    instance2_db_status = check_db_health("3.129.250.41", "5001", "root", "coupons1001", "cpsc559")
    instance3_db_status = check_db_health("3.129.250.41", "5002", "root", "coupons1001", "cpsc559")
    instance4_db_status = check_db_health("3.129.250.41", "5003", "root", "coupons1001", "cpsc559")
    
    if instance1_db_status is False:
        print('INSTANCE 1 DOWN!')
        response = ssm_client.send_command(
            InstanceIds=['i-08b0fa8a4c5a45643'],
            DocumentName='AWS-RunShellScript',
            Parameters={
                'commands': [
                    'sudo docker start coupon-db-1'
                ]
            }
        )
    if instance2_db_status is False:
        print('INSTANCE 2 DOWN!')
        response = ssm_client.send_command(
            InstanceIds=['i-08b0fa8a4c5a45643'],
            DocumentName='AWS-RunShellScript',
            Parameters={
                'commands': [
                    'sudo docker start coupon-db-2'
                ]
            }
        )
    if instance3_db_status is False:
        print('INSTANCE 3 DOWN!')
        response = ssm_client.send_command(
            InstanceIds=['i-08b0fa8a4c5a45643'],
            DocumentName='AWS-RunShellScript',
            Parameters={
                'commands': [
                    'sudo docker start coupon-db-3'
                ]
            }
        )
    if instance4_db_status is False:
        print('INSTANCE 4 DOWN!')
        response = ssm_client.send_command(
            InstanceIds=['i-08b0fa8a4c5a45643'],
            DocumentName='AWS-RunShellScript',
            Parameters={
                'commands': [
                    'sudo docker start coupon-db-4'
                ]
            }
        )
    
    return {}