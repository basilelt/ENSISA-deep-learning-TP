#!/bin/bash

curl -X POST "http://172.17.0.2:80/config"
curl -X POST "http://172.17.0.2:80/validate"
