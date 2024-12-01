print("Custom startup loaded")

# # Override the database engine
# settings.DATABASES['default']['ENGINE'] = 'django.db.backends.postgresql'

# # You could also override other settings like NAME, USER, PASSWORD, etc.
# settings.DATABASES['default']['NAME'] = 'my_postgres_db'
# settings.DATABASES['default']['USER'] = 'my_user'
# settings.DATABASES['default']['PASSWORD'] = 'my_password'
# settings.DATABASES['default']['HOST'] = 'localhost'
# settings.DATABASES['default']['PORT'] = '5432'

# print("Custom database settings applied!")

# print(settings.DATABASES)


CUSTOM_PERMISSIONS = [
    {"codename": "config_specific", "name": "Config specific permission"},
]
