#!/bin/bash 

no_filename() {
    echo "Please provide a name for the compose file you want to test."
    exit 1
}

file_does_not_exist() {
    echo "A file with that name does not exist. Please choose an existing file."
    exit 1
}

if [ -z $1 ]
then
    no_filename
elif [ ! -f $1 ]
then
    file_does_not_exist
else
    # Tear down the application and delete the volumes if they exist
    docker-compose -f $1 down
    docker volume rm vmware_mariadb_data
    docker volume rm vmware_ghost_data

    # Launch application
    docker-compose -f $1 up -d
fi

exit 0
