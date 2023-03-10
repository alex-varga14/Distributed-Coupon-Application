from backendapp.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'cpsc559',
        'USER':'root',
        'PASSWORD':'coupons1001',
        'HOST':'3.144.123.146', # this server is meant to be run on EC2
        'PORT': '5001',
    }
}

GRPC_PORT=50001

