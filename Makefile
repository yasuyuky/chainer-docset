SHELL := /bin/bash

PYTHON = python3.7
VERSION = v$(shell grep chainer requirements.txt| cut -f 3 -d '=')
REMOVE = .venv/lib/$(PYTHON)/site-packages

all: Chainer.docset.zip

chainer:
	git clone https://github.com/chainer/chainer
	cd chainer && git pull
	cd chainer && git checkout tags/$(VERSION)

.venv:
	$(PYTHON) -m venv .venv
	source .venv/bin/activate && pip install -r requirements.txt

chainer/docs/build/html: .venv chainer
	source .venv/bin/activate && cd chainer/docs && make html
	grep $(REMOVE) -a -l -r chainer/docs/build/html | xargs sed -i -e "s|$(REMOVE)||g"

chainer_icon_red.png:
	curl -LO https://chainer.org/images/chainer_icon_red.png

Chainer.docset: chainer_icon_red.png chainer/docs/build/html
	source .venv/bin/activate && \
	doc2dash -n Chainer -i chainer_icon_red.png -j chainer/docs/build/html

Chainer.docset.zip: Chainer.docset
	zip -9 -r Chainer.docset.zip Chainer.docset

.PHONY: clean release

release:
	source .venv/bin/activate && \
	githubrelease release yasuyuky/chainer-docset create $(VERSION) --publish --name "$(VERSION)" Chainer.docset.zip

clean:
	rm -rf chainer .venv chainer_icon_red.png Chainer.docset*
