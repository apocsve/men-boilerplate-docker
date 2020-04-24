#!/bin/bash
set -e

while ! nc -z men-mongo 27017 ;
do
    echo "############# Waiting for men-mongo to start.";
    sleep 3;
done;