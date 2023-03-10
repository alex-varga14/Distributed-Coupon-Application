from backendapp.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'cpsc559',
        'USER':'root',
        'PASSWORD':'coupons1001',
        'HOST':'localhost', # this server is meant to be run on EC2
        'PORT': '5000',
    }
}

GRPC_PORT=50000

