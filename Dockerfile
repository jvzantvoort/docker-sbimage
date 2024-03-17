FROM python:3.13.0a5-bullseye

LABEL \
  maintainer="john@vanzantvoort.org" \
  description="site builder image"

# add the python requirements file
ADD requirements.txt /tmp/requirements.txt
ADD puppet-pygments-lexer-0.0.1.tar.gz /tmp

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
RUN cd /tmp/puppet-pygments-lexer-0.0.1; \
    python setup.py install; \
    cd /tmp

WORKDIR /code
VOLUME ["/webroot"]
VOLUME ["/output"]

CMD ["/bin/bash"]
