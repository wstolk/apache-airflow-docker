# Apache Airflow docker-compose

**Currently using Apache Airflow 1.10.10**

Docker Compose files for setting up an Apache Airflow environment (LocalExecutor). 
The project is build upon the latest stable build of the 
official [Apache Airflow docker image](https://hub.docker.com/r/apache/airflow).

It is currently by no means meant to be used in a production environment.

## Prerequisites

* Docker
* Docker Compose

## Setup Instructions

* Clone repository
* Execute `docker-compose up`

## Example docker-compose.yml

```yaml
version: '2.1'
services:
  postgres:
    image: postgres:9.6
    container_name: airflow_postgres
    environment:
      - POSTGRES_USER=airflow
      - POSTGRES_PASSWORD=${POSTGRES_PW-airflow}
      - POSTGRES_DB=airflow
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - ./volumes/postgres_data:/var/lib/postgresql/data/pgdata:Z
    ports:
      - 127.0.0.1:5432:5432

  webserver:
    image: wstolk/apache-airflow:latest
    restart: always
    depends_on:
      - postgres
    container_name: airflow_webserver
    logging:
      options:
        max-size: 10m
        max-file: "3"
    environment:
      - AIRFLOW__WEBSERVER__RBAC=false
      - AIRFLOW__CORE__EXECUTOR=SequentialExecutor
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgres://airflow:${POSTGRES_PW-airflow}@postgres:5432/airflow
      - AIRFLOW__CORE__FERNET_KEY=${AF_FERNET_KEY-GUYoGcG5xdn5K3ysGG3LQzOt3cc0UBOEibEPxugDwas=}
      - AIRFLOW__CORE__AIRFLOW_HOME=/opt/airflow/
      - AIRFLOW__CORE__LOAD_EXAMPLES=False
      - AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS=False
    volumes:
      - ../airflow/dags:/opt/airflow/dags:z
      - ../airflow/plugins:/opt/airflow/plugins:z
      - ./volumes/airflow_data_dump:/opt/airflow/data_dump:z
      - ./volumes/airflow_logs:/opt/airflow/logs:z
    ports:
      - "8080:8080"
    networks:
      - proxy
      - default
    command: webserver
    healthcheck:
      test: ["CMD-SHELL", "[ -f /opt/airflow/airflow-webserver.pid ]"]
      interval: 30s
      timeout: 30s
      retries: 3

networks:
  proxy:
    external: false
```

## Credits

This repository is heavily inspired on the setup provided by 
Github user [KimchaC](https://github.com/puckel/docker-airflow/issues/536#issuecomment-626333283).