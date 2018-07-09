#!/usr/bin/env bash

PYTHON=python3.6
VERSION=v$(grep chainer requirements.txt| cut -f 3 -d '=')

git clone https://github.com/chainer/chainer
cd chainer/docs

${PYTHON} -m venv .venv
source .venv/bin/activate
pip install -r ../../requirements.txt
git checkout ${VERSION}
make html
FROM="docs/.venv/lib/${PYTHON}/site-packages"
for f in $(grep $FROM -a -l -r build); do sed -i -e "s|$FROM||g" $f; done
curl -LO https://chainer.org/images/chainer_icon_red.png
doc2dash -n Chainer -i chainer_icon_red.png -j build/html
zip -9 -r Chainer.docset.zip Chainer.docset
