
IMAGEBASE := "jvzantvoort/sbimage"
TAGBASE := "sbimage-"
GITTAG ?= $(shell git describe --abbrev=0 --tags)
LASTVERSION := $(shell git describe --abbrev=0 --tags|sed 's,sbimage-,,')
GITDIFF := $(shell git diff $(GITTAG)..HEAD)

define ntag
	var=$(TAGBASE); \
	newtag=`echo $(1) |  sed "s,$$var,," | awk -v tn=$(TAGBASE) '{ printf "%s%d", tn, $$0 + 1}'`; \
	git tag $$newtag
endef

.PHONEY: tag build clean push

ifneq ($(GITDIFF),)
	LASTVERSION = "test"
endif

NAME ?= $(shell echo $(IMAGEBASE):$(LASTVERSION))

tag:
	@$(call ntag,$(GITTAG))

all: build

clean:
	@docker ps -a -q  --filter ancestor=$(NAME) | xargs -I {} docker rm 
	docker rmi $(NAME) || echo "oke"

build: clean
	docker build -t $(NAME) --file Dockerfile --rm .

push:
	docker push $(NAME)
