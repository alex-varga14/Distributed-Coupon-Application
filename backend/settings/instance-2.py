from backendapp.settings import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'coupondb',
        'USER':'root',
        'PASSWORD':'coupons1001',
        'HOST':'3.145.15.144',
        'PORT': '5001',
    }
}

