#!/usr/bin/env bash
#
#
if [ ! -d venv ]
then
	python3 -m venv venv
fi

if [ -x venv/bin/activate ]
then
	source venv/bin/activate
fi

venv/bin/pip3 install -r requirements.txt
