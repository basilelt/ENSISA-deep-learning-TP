#!/bin/bash

curl -X POST "http://172.17.0.2:80/config"
curl -X POST "http://172.17.0.2:80/validate"
curl -X POST "http://172.17.0.2:80/check?id=1"
curl -X POST "http://172.17.0.2:80/classify" -F "file=@ia/pictures/piano.jpg"
