FROM python:3.9.9-slim-bullseye AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

FROM base AS python-deps

# Install pipenv and compilation dependencies
RUN apt-get update && apt-get install -y gettext && apt-get install -y --no-install-recommends gcc
RUN pip install --upgrade pip

# Install python dependencies in /.venv
COPY /src/requirements.txt /
RUN pip install -r ./requirements.txt

WORKDIR /src
COPY /src /src

RUN chmod +x ./entrypoint.sh

FROM python-deps AS dev