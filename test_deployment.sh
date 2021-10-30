#!/bin/bash 

no_filename() {
    echo "Please provide a name for the compose file you want to test."
    exit 1
}

file_does_not_exist() {
    echo "A file with that name does not exist. Please choose an existing file."
    exit 1
}

CONTAINER_PREFIX=$(basename $PWD)

if [ -z $1 ]
then
    no_filename
elif [ ! -f $1 ]
then
    file_does_not_exist
else
    # Tear down the application and delete the volumes if they exist
    docker-compose -f $1 down
    docker volume rm ${CONTAINER_PREFIX}_ghost_data
    docker volume rm ${CONTAINER_PREFIX}_mariadb_data

    # Launch application
    docker-compose -f $1 up -d

    # Smoke Test 1: Check that containers are up and running
    # Check Ghost container
    GHOST_CONTAINER_RUNNING=$(docker ps | awk '/_ghost_1/ && /Up/ { print; }' | wc -l)
    if [[ "$GHOST_CONTAINER_RUNNING" -eq 1 ]]
    then
        echo "Ghost container is running. Test successful."
    else
        echo "Ghost container is not running. Test failed."
        exit 1
    fi
    # Check MariaDB container
    MARIADB_CONTAINER_RUNNING=$(docker ps | awk '/_ghost_1/ && /Up/ { print; }' | wc -l)
    if [[ "$MARIADB_CONTAINER_RUNNING" -eq 1 ]]
    then
        echo "MariaDB container is running. Test successful."
    else
        echo "MariaDB container is not running. Test failed."
        exit 1
    fi
fi

exit 0
