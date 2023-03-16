from django.apps import AppConfig
import os

class BackendcoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'backendcore'

    # called once
    def ready(self):
        print(f"pid: {os.getpid()}")
        pass


