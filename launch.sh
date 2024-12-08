#!/bin/bash

(cd julia && julia --project main.jl) &
cd vue && npx serve dist -s -l 80