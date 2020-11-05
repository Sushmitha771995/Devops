#!/bin/bash

# functions in shell scripting
# functons is calling a group of commands as a single command :P

abc()
{ echo this is a function abc
 read -p "enter your name" name
 case $name in
 sushmitha)
   echo hello $name
   ;;
 navyatha)
   echo hey $name
   ;;
 esac

}
abc

