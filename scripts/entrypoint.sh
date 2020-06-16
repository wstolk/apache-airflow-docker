#!/bin/bash

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    airflow initdb || echo "Database already initialised"
    airflow scheduler &
    exec airflow webserver
else
    airflow scheduler &
    exec airflow webserver
fi