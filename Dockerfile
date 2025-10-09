FROM python:3

LABEL \
  maintainer="john@vanzantvoort.org" \
  description="site builder image"

# add the python requirements file
ADD requirements.txt /tmp/requirements.txt

# runtime dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libldap2-dev \
		libsasl2-dev \
		rsync \
	; \
	rm -rf /var/lib/apt/lists/*

RUN pip install -U pip && pip install -r /tmp/requirements.txt

WORKDIR /code
VOLUME ["/webroot"]
VOLUME ["/output"]

CMD ["/bin/bash"]
