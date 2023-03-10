from backendapp.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'cpsc559',
        'USER':'root',
        'PASSWORD':'coupons1001',
        'HOST':'3.145.15.144',
        'PORT': '5000',
    }
}

GRPC_PORT=50000

