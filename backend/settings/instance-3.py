from backendapp.settings import *

REPLICAS = [
    "http://3.145.15.144:8000",
    "http://3.145.15.144:8001",
    "http://3.145.15.144:8002",
    "http://3.145.15.144:8003",
]


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'cpsc559',
        'USER':'root',
        'PASSWORD':'coupons1001',
        'HOST':'localhost', # this server is meant to be run on EC2
        'PORT': '5002',
    }
}

GRPC_PORT=50002


