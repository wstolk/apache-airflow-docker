# Airflow variables
ARG AIRFLOW_VERSION=1.10.10
ARG AIRFLOW_USER_HOME=/opt/airflow/
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ARG DOCKER_UID=docker-airflow-1000

# Load latest official Airflow image as base
FROM apache/airflow:${AIRFLOW_VERSION}

LABEL maintainer="wstolk"

# Install DAG dependencies
USER root
RUN apt-get update -yqq \
    && apt-get install -y gcc \
    && apt-get install -y git
RUN pip install apache-airflow[gcp_api,requests,slackclient,slack,google-api-python-client,google-auth]

# This fixes permission issues on linux.
# The airflow user should have the same UID as the user running docker on the host system.
RUN \
    : "${DOCKER_UID:?Build argument DOCKER_UID needs to be set and non-empty.}" \
    && usermod -u ${DOCKER_UID} airflow \
    && find / -path /proc -prune -o -user 50000 -exec chown -h airflow {} \; \
    && echo "Set airflow's uid to ${DOCKER_UID}"

COPY scripts/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]

USER airflow
