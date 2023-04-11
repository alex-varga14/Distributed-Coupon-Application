"""
WSGI config for backendapp project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/
"""

import os

import logging.config
import boto3
import sys
import re

from django.conf import settings

from django.core.wsgi import get_wsgi_application
from backendcore import models
from django.db import connection
from datetime import datetime
import time
import subprocess

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backendapp.settings')

# ssm = boto3.client('ssm', 'us-east-2')

# logging.config.dictConfig(settings.LOGGING)

application = get_wsgi_application()

from backendcore.sync import syncserver
syncserver.serve()

# OLD CONSISTENCY MECHANISM
# print('CONSISTENCY CHECK')
# i1 = False
# i2 = False
# i3 = False
# i4 = False
# if sys.argv[2] == "0.0.0.0:8000":
#     i1 = True
#     param = ssm.get_parameter(Name='/instance-1/last-executed-query', WithDecryption=True)
# elif sys.argv[2] == "0.0.0.0:8001":
#     i2 = True
#     param = ssm.get_parameter(Name='/instance-2/last-executed-query', WithDecryption=True)
# elif sys.argv[2] == "0.0.0.0:8002":
#     i3 = True
#     param = ssm.get_parameter(Name='/instance-3/last-executed-query', WithDecryption=True)
# elif sys.argv[2] == "0.0.0.0:8003":
#     i4 = True
#     param = ssm.get_parameter(Name='/instance-4/last-executed-query', WithDecryption=True)
# print(param['Parameter']['Value'])

# found = False
# #j = 0
# old_op = ""
# ts_pattern = re.compile("(?P<date>\d{4}[-]?\d{1,2}[-]?\d{1,2} \d{1,2}:\d{1,2}:\d{1,2})")
# for i, line in enumerate(open('/home/ubuntu/Distributed-Coupon-Application/backend/backendapp/django-query.log')):
#     for match in re.finditer(ts_pattern, line):
#         if(match.group() == param['Parameter']['Value']):
#             print('Last EXECUTED Timestamp Found')
#             found = True
#     if(found):
#         #print('Found missing operation on line %s: %s' % (i+1, match.group()))
#         op = re.search("INSERT\s+INTO\s+`?(\w+)`?\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\);", line)
#         if(op):
#             cursor = connection.cursor()
#             cursor.execute("INSERT IGNORE INTO `" + op.group(1) + "` (" + op.group(2) + ") VALUES (" + op.group(3) + ");")

# r = subprocess.run(['tail', '-1', '/home/ubuntu/Distributed-Coupon-Application/backend/backendapp/django-query.log'], stdout=subprocess.PIPE)

# txn = re.search("(?P<date>\d{4}[-]?\d{1,2}[-]?\d{1,2} \d{1,2}:\d{1,2}:\d{1,2})", str(r.stdout))
# print('LAST OPERATION - ' + txn.group())
# if(i1):
#     ssm.put_parameter(Name='/instance-1/last-executed-query', Overwrite=True, Value=txn.group(),)
# elif(i2):
#     ssm.put_parameter(Name='/instance-2/last-executed-query', Overwrite=True, Value=txn.group(),)
# elif(i3):
#     ssm.put_parameter(Name='/instance-3/last-executed-query', Overwrite=True, Value=txn.group(),)
# elif(i4):
#     ssm.put_parameter(Name='/instance-4/last-executed-query', Overwrite=True, Value=txn.group(),)