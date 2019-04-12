
IMAGEBASE := "jvzantvoort/sbimage"
GITTAG ?= $(shell git describe --abbrev=0 --tags)
LASTVERSION := $(shell git describe --abbrev=0 --tags|sed 's,sbimage-,,')
GITDIFF := $(shell git diff $(GITTAG)..HEAD)

ifneq ($(GITDIFF),)
	LASTVERSION = "test"
endif

NAME ?= "$(IMAGEBASE):$(LASTVERSION)"

all:
	@echo $(GITTAG); \
	echo $(NAME)

build:
	docker rmi $(NAME) || echo "oke"
	docker build -t $(NAME) --file Dockerfile --rm .
