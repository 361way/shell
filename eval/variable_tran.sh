#!/bin/bash
a='my'
b='site'
my_site='my site www.361way.com'
echo a_b is "$a"_"$b"
echo $("$a"_"$b")
web="$a"_"$b"
echo web is $web
eval echo '$'"$a"_"$b"
eval echo '$'{"$a"_"$b"}
