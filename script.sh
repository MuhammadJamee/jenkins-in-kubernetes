#!/bin/bash
git clone git@github.com:MuhammadJamee/jenkins-in-kubernetes.git
cd jenkins-in-kubernetes
kubectl -n jenkins apply -f ./