#!/bin/bash

docker build -t basilelt/tensorflow-arm64:2.8.0 .
docker push basilelt/tensorflow-arm64:2.8.0
