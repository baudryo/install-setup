#!/bin/bash

# Hide all output by default
#exec 3>&1 &>/dev/null
exec 3>&1 1>/dev/null

echo -n "outputting text to file... " >&3
echo "hello world" > ~/"hello_world_output.txt"
echo "I am hidden from output"
echo "Done" >&3
#p s>&3
p
echo toto
