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

if [[ -z $1 ]]
then
    no_filename
elif [[ ! -f $1 ]]
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
    echo ""
    echo "**************************************************"
    echo ""
    echo "---> Starting execution of Test 1: check containers status"
    echo ""
    # Check Ghost container
    GHOST_CONTAINER_RUNNING=$(docker ps | awk '/_ghost_1/ && /Up/ { print; }' | wc -l)
    if [[ "$GHOST_CONTAINER_RUNNING" -eq 1 ]]
    then
        echo "Ghost container is running. TEST SUCCESSFUL."
    else
        echo "Ghost container is not running. TEST FAILED."
        exit 1
    fi
    # Check MariaDB container
    MARIADB_CONTAINER_RUNNING=$(docker ps | awk '/_mariadb_1/ && /Up/ { print; }' | wc -l)
    if [[ "$MARIADB_CONTAINER_RUNNING" -eq 1 ]]
    then
        echo "MariaDB container is running. TEST SUCCESSFUL."
    else
        echo "MariaDB container is not running. TEST FAILED."
        exit 1
    fi

    # Smoke Test 2: Apply test queries in database
    echo ""
    echo "**************************************************"
    echo ""
    echo "---> Starting execution of Test 2: check basic database queries"
    echo ""
    # The test is implemented in Java 11 in the ./db-smoke-test dir

    # Parse db name, user and password from compose file
    export DB_NAME=$(grep "MARIADB_DATABASE=" $1 | sed -e "s/.*=//")
    [[ -z "$DB_NAME" ]] && DB_NAME="bitnami_ghost"
    export DB_USER=$(grep "MARIADB_USER=" $1 | sed -e "s/.*=//")
    [[ -z "$DB_USER" ]] && DB_USER="bn_ghost"
    export DB_PASSWORD=$(grep "MARIADB_PASSWORD=" $1 | sed -e "s/.*=//")
    [[ -z "$DB_PASSWORD" ]] && DB_PASSWORD="dbpassword"
    
    # Launch DB test with Maven and evaluate test exit status
    # The test will use the previously exported variables
    mvn -f ./db-smoke-test exec:java -Dexec.mainClass="io.eduriol.MariaDBTest"
    if [[ "$?" -eq 0 ]]
    then
        echo "Basic operations were performed in MariaDB. TEST SUCCESSFUL."
    else
        echo "Unable to perform basic operations in MariaDB. TEST FAILED."
        exit 1
    fi


    # Smoke Test 3: Log in the Ghost application
    echo ""
    echo "**************************************************"
    echo ""
    echo "---> Starting execution of Test 3: log in the Ghost app"
    echo ""
    # The test is implemented in Java 11 in the ./ui-smoke-test dir

    # Parse user mail, password and port from compose file
    export EMAIL=$(grep "GHOST_EMAIL=" $1 | sed -e "s/.*=//")
    [[ -z "$EMAIL" ]] && EMAIL="user@example.com"
    export PASSWORD=$(grep "GHOST_PASSWORD=" $1 | sed -e "s/.*=//")
    [[ -z "$PASSWORD" ]] && PASSWORD="bitnami123"
    export PORT=$(grep "GHOST_EXTERNAL_HTTP_PORT_NUMBER=" $1 | sed -e "s/.*=//")
    [[ -z "$PORT" ]] && PORT="80"

    # Launch UI test with Maven and evaluate test exit status
    # The test will use the previously exported variables
    mvn -f ./ui-smoke-test exec:java -Dexec.mainClass="io.eduriol.GhostUITest"
    if [[ "$?" -eq 0 ]]
    then
        echo "Log in the Ghost UI worked. TEST SUCCESSFUL."
    else
        echo "Unable to log in the Ghost UI. TEST FAILED."
        exit 1
    fi
fi

echo ""
echo "**************************************************"
echo ""
echo "---> ALL THE TESTS WERE EXECUTED SUCCESSFULLY <---"
echo ""
echo "**************************************************"
echo ""

exit 0
