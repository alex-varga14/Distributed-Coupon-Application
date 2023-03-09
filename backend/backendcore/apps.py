from django.apps import AppConfig

class BackendcoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'backendcore'

    # called once
    def ready(self):
        pass


