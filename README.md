# django-docker-basics
Basic configuration to run Django on a Docker container.
It has been made using [this](https://github.com/docker/awesome-compose/tree/master/official-documentation-samples/django/) guide and it is strongly recommended to follow it.

Just a few things:
- The settings.py file of the core application of the Django project is meant to be modified:

```
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = os.environ.get('DEBUG')

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS').split(' ')
```
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_NAME'),
        'USER': os.environ.get('POSTGRES_USER'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
        'HOST': os.environ.get('POSTGRES_HOST'),
        'PORT': os.environ.get('POSTGRES_PORT'),
    }
}
```

- The .gitignore file can be updated with "Dockerfile" and "docker-compose.yml".
