# syntax=docker/dockerfile:1
FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
RUN apt-get update
# optional: install pytailwindcss if you want the Tailwind CLI
RUN pip install pytailwindcss
# optional: intall gettext for translations
RUN apt-get install gettext -y
COPY . /code/
