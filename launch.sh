#!/bin/bash

# Determine the base directory
if [ -d "/app" ]; then
    # We're in Docker
    BASE_DIR="/app"
else
    # We're running locally
    BASE_DIR="."
fi

if [ "$VITE_ENV" = "production" ]; then
    cd $BASE_DIR/julia && julia --project main.jl
else
    cd $BASE_DIR/julia && julia --project main.jl &
    cd $BASE_DIR/vue && yarn dev

    wait
fi
