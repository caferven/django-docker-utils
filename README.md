# django-docker-basics
Basic configuration to run Django on a Docker container.
It has been made using [this](https://github.com/docker/awesome-compose/tree/master/official-documentation-samples/django/) guide and it is strongly recommended to follow it.

**REQUIREMENTS:** docker and docker-compose should be installed in order to follow these steps.

- Create the Dockerfile:

```docker
# syntax=docker/dockerfile:1
FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
COPY . /code/
```

- And the docker-compose.yml file:

```yaml
services:
  db:
    image: postgres
    volumes:
      - ./data/db:/var/lib/postgresql/data
    env_file:
      - ./.env
    ports:
      - "5432:5432"
      
  web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/code
      - ./media:/code/media
    ports:
      - "8000:8000"
    env_file:
        - ./.env
    depends_on:
      - db
volumes:
  media:
```

<aside>
☝ It is important to add the media volume or the instance won’t be able to find the existing media.

</aside>

- The requirements.txt file exists in every Django project:

```
Django>=3.0,<4.0
psycopg2>=2.8
```

- In the docker-compose.yml file we have already specified the env_file and it should look like this one:

```
POSTGRES_DB=postgres
OSTGRES_NAME=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432
SECRET_KEY=
DEBUG=False
ALLOWED_HOSTS=localhost 127.0.0.1
EMAIL_USER=
EMAIL_PASS=
```

Just a few things:

- The [settings.py](http://settings.py/) file of the core application of the Django project is meant to be modified:

```
from decouple import config # type: ignore

[...]

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = config('DEBUG')

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS').split(' ')

[...]

EMAIL_HOST_USER = config('EMAIL_USER')
EMAIL_HOST_PASSWORD = config('EMAIL_PASS')
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
- Remember that in order to run any command that uses "[migrate.py](http://migrate.py/)" you'll need to use "docker-compose run --rm web python [manage.py](http://manage.py/)".
- Some parameters need to be processed through config() and not os.environ.get(). To be able to do this, it is necessary to import decouple.
