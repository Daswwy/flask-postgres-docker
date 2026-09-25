#!/bin/bash

echo "Turning off 10.0.2.5"
ssh target-user@10.0.2.5 "sudo poweroff"

echo "10.0.2.5 down"
echo "Turning off local machine..."

sudo poweroff
