#!/bin/bash
cd /opt
git clone https://github.com/anmiroshnichenko/docker-in-practice.git
cd  docker-in-practice && docker compose up -d   
docker compose ps -a 