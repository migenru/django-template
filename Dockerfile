FROM python:3.10.3-slim-bullseye AS base

RUN apt-get update && apt-get install -y gettext

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1


FROM base AS builder

RUN pip install --upgrade pip

RUN pip install pipenv

WORKDIR /src
COPY /src /src

COPY Pipfile Pipfile.lock ./

RUN pipenv install --system --deploy --ignore-pipfile


ENV _UWSGI_VERSION 2.0.19

RUN wget -O uwsgi-${_UWSGI_VERSION}.tar.gz https://github.com/unbit/uwsgi/archive/${_UWSGI_VERSION}.tar.gz \
    && tar zxvf uwsgi-*.tar.gz \
    && UWSGI_BIN_NAME=/usr/local/bin/uwsgi make -C uwsgi-${_UWSGI_VERSION} \
    && rm -Rf uwsgi-*

RUN ls
RUN chmod 777 ./entrypoint.sh

CMD uwsgi --master --http :8000 --module app.wsgi --workers 2 --threads 2 --harakiri 25 --max-requests 1000 --log-x-forwarded-for --buffer-size 32000


FROM builder AS dev