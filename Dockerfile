# Custom Dockerfile
FROM apache/airflow:1.10.10

# Install mssql support & dag dependencies
USER root
RUN apt-get update -yqq \
    && apt-get install -y gcc \
    && apt-get install -y git
RUN pip install apache-airflow[gcp_api,requests,slackclient,slack,google-api-python-client,google-auth]

# This fixes permission issues on linux.
# The airflow user should have the same UID as the user running docker on the host system.
# make build is adjust this value automatically
ARG DOCKER_UID
RUN \
    : "${DOCKER_UID:?Build argument DOCKER_UID needs to be set and non-empty. Use 'make build' to set it automatically.}" \
    && usermod -u ${DOCKER_UID} airflow \
    && find / -path /proc -prune -o -user 50000 -exec chown -h airflow {} \; \
    && echo "Set airflow's uid to ${DOCKER_UID}"

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

USER airflow
