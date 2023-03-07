from django.apps import AppConfig
from backendcore.sync import syncserver

class BackendcoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'backendcore'

    # called once
    def ready(self):
        syncserver.serve()


