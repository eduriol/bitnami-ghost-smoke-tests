#!/bin/bash

# Define port for Ghost app
export PORT=8001

# Tear down the application if it is deployed already
helm delete my-release
kubectl delete pvc data-my-release-mariadb-0

# Get and launch application
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/ghost --set ghostHost=127.0.0.1

# Smoke Test 1: Check that pods are up and running
echo ""
echo "**************************************************"
echo ""
echo "---> Starting execution of Test 1: check pods status"
echo ""
# Check Ghost pod
GHOST_POD_RUNNING=0
for i in {1..10}
do
    GHOST_POD_RUNNING=$(kubectl get pods | awk '/-ghost-/ && /Running/ { print; }' | wc -l)
    if [[ "$GHOST_POD_RUNNING" -eq 0 ]]
    then
        echo "Ghost pod still not running..."
    else
        break
    fi
    sleep 5
done
if [[ "$GHOST_POD_RUNNING" -eq 1 ]]
then
    echo "Ghost pod is running. TEST SUCCESSFUL."
else
    echo "Ghost pod is not running. TEST FAILED."
    exit 1
fi
# Check MariaDB pod
for i in {1..10}
do
    MARIADB_POD_RUNNING=$(kubectl get pods | awk '/-mariadb-/ && /Running/ { print; }' | wc -l)
    if [[ "$MARIADB_POD_RUNNING" -eq 0 ]]
    then
        echo "MariaDB pod still not running..."
    else
        break
    fi
    sleep 5
done
if [[ "$MARIADB_POD_RUNNING" -eq 1 ]]
then
    echo "MariaDB pod is running. TEST SUCCESSFUL."
else
    echo "MariaDB pod is not running. TEST FAILED."
    exit 1
fi

# # Smoke Test 2: Apply test queries in database
# echo ""
# echo "**************************************************"
# echo ""
# echo "---> Starting execution of Test 2: check basic database queries"
# echo ""
# # The test is implemented in Java 11 in the ./db-smoke-test dir

# # Parse db name, user and password from compose file
# export DB_NAME=$(grep "MARIADB_DATABASE=" $1 | sed -e "s/.*=//")
# [[ -z "$DB_NAME" ]] && DB_NAME="bitnami_ghost"
# export DB_USER=$(grep "MARIADB_USER=" $1 | sed -e "s/.*=//")
# [[ -z "$DB_USER" ]] && DB_USER="bn_ghost"
# export DB_PASSWORD=$(grep "MARIADB_PASSWORD=" $1 | sed -e "s/.*=//")
# [[ -z "$DB_PASSWORD" ]] && DB_PASSWORD="dbpassword"

# # Launch DB test with Maven and evaluate test exit status
# # The test will use the previously exported variables
# mvn -f ./db-smoke-test package
# mvn -f ./db-smoke-test exec:java -Dexec.mainClass="io.eduriol.MariaDBTest"
# if [[ "$?" -eq 0 ]]
# then
#     echo "Basic operations were performed in MariaDB. TEST SUCCESSFUL."
# else
#     echo "Unable to perform basic operations in MariaDB. TEST FAILED."
#     exit 1
# fi

# Open port for UI test after checking that it is not being used
pkill -f "kubectl port-forward svc/my-release-ghost ${PORT}:80"
kubectl port-forward svc/my-release-ghost ${PORT}:80 &> /dev/null &

# Smoke Test 3: Log in the Ghost application
echo ""
echo "**************************************************"
echo ""
echo "---> Starting execution of Test 3: log in the Ghost app"
echo ""
# The test is implemented in Java 11 in the ./ui-smoke-test dir

# Export user mail and password
export EMAIL=user@example.com
export PASSWORD=$(kubectl get secret --namespace default my-release-ghost -o jsonpath="{.data.ghost-password}" | base64 --decode)

# Launch UI test with Maven and evaluate test exit status
# The test will use the previously exported variables
mvn -f ./ui-smoke-test package
mvn -f ./ui-smoke-test exec:java -Dexec.mainClass="io.eduriol.GhostUITest"
if [[ "$?" -eq 0 ]]
then
    echo "Log in the Ghost UI worked. TEST SUCCESSFUL."
else
    echo "Unable to log in the Ghost UI. TEST FAILED."
    exit 1
fi

echo ""
echo "**************************************************"
echo ""
echo "---> ALL THE TESTS WERE EXECUTED SUCCESSFULLY <---"
echo ""
echo "**************************************************"
echo ""

exit 0
