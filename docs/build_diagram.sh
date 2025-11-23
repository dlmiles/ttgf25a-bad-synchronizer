#!/bin/bash
#
#  docker run -v "$(pwd):/tmp/work:Z" -ti ubuntu:latest
#

# For inside clean Docker
if ! test -e /etc/localtime
then
	ln -fs /usr/share/zoneinfo/UTC /etc/localtime
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
	dpkg-reconfigure --fontend noninteractive txdata
fi

DEBIAN_FRONTEND=noninteractive apt-get install texlive-full librsvg2-bin potrace

tlmgr init-usertree

tlmgr update --self --all

tlmgr search circuitikz tikz
tlmgr info tikz
tlmgr info circuitikz

pdflatex diagram_tikz.tex
pdftops -eps diagram_tikz.pdf
convert -density 600x600 diagram_tikz.pdf -quality 95 -resize 1280x640 diagram_tikz_alpha.png
convert -density 600x600 diagram_tikz.pdf -quality 95 -resize 1280x640 -background '#fffff4' -alpha remove -alpha off diagram_tikz.png

#convert diagram_tikz.pdf diagram_tikz.svg

