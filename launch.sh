#!/bin/bash

if [ "$VITE_ENV" = "production" ]; then
    cd julia && julia --project main.jl
else
    cd julia && julia --project main.jl & 
    cd vue && yarn dev
    
    wait
fi

