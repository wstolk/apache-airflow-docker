# Load latest official Airflow image as base
FROM apache/airflow:1.10.10
LABEL maintainer="wstolk"

# Airflow variables
ARG AIRFLOW_VERSION=1.10.10
ARG AIRFLOW_USER_HOME=/opt/airflow/
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""

USER root

RUN apt-get update -yqq \
    && apt-get install -y gcc \
    && apt-get install -y git

RUN pip install apache-airflow[gcp_api,requests,google-api-python-client,google-auth${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip install 'redis==3.2' \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi

COPY script/entrypoint.sh /entrypoint.sh

RUN chown -R airflow: ${AIRFLOW_USER_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]