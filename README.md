# django-docker-utils
Personal basic configuration to run Django on a Docker container.
It is strongly recommended to follow the [awesome-compose](https://github.com/docker/awesome-compose/tree/master/official-documentation-samples/django/) guide previously.

**REQUIREMENTS:** docker and docker-compose should be installed in order to follow these steps.

- Create the Dockerfile (note that there are optional commands):

```docker
FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
RUN apt-get update
# optional: intall gettext for translations
RUN apt-get install gettext -y
COPY . /code/
```

- And the docker-compose.yml file (note that there's a locale directory just in case there are translations within the project):

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
      - ./locale:/code/locale
      - ./static:/code/static
    ports:
      - "8000:8000"
    env_file:
        - ./.env
    depends_on:
      - db
volumes:
  media:
  locale:
  static:
```

<aside>
☝ It is important to add the media volume or the instance won’t be able to find the existing media.

</aside>


- The requirements.txt file exists in every Django project:

```
django
psycopg2
pillow
python-decouple
# optional: install django-crispy-forms
django-crispy-forms
# optional: install pytailwindcss if you want the Tailwind CLI
pytailwindcss
# optional: install django- if you want the Tailwind CLI
pytailwindcss

# optional: add a specific version
```

- In the docker-compose.yml file we have already specified the env_file and it should look like this one:

```
POSTGRES_DB=postgres
POSTGRES_NAME=postgres
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

# Internationalization (this is an example of a project that is translated to Spanish)
# https://docs.djangoproject.com/en/5.1/topics/i18n/

LANGUAGE_CODE = 'es'

LANGUAGES = (
    ('es', _('Spanish')),
    ('en', _('English')),
)

LOCALE_PATHS = (os.path.join(BASE_DIR, 'locale'),)

TIME_ZONE = 'Europe/Madrid'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.1/howto/static-files/

STATIC_URL = '/static/'
STATICFILES_DIRS = [
    BASE_DIR / 'static',
]

MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
MEDIA_URL = '/media/'

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
- To enter the docker terminal, run: docker-compose exec web bash
- To update the Tailwind CSS output.css file, run: tailwindcss -i static/css/input.css -o static/css/output.css (if the config file is located at .)
- Note that this is in case you use a PostgreSQL database.