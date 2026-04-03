FROM python:3.13-slim

LABEL \
  maintainer="john@vanzantvoort.org" \
  description="site builder image"

# add the python requirements file
COPY requirements.txt /tmp/requirements.txt

# runtime dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libldap2-dev \
		libsasl2-dev \
		rsync \
		git \
	; \
	rm -rf /var/lib/apt/lists/*

# Install Python packages with cache mount for faster rebuilds
RUN --mount=type=cache,target=/root/.cache/pip \
	pip install --no-cache-dir -U pip setuptools wheel && \
	pip install --no-cache-dir -r /tmp/requirements.txt && \
	rm /tmp/requirements.txt

WORKDIR /code
VOLUME ["/webroot"]
VOLUME ["/output"]

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python3 -c "import sphinx; print('OK')" || exit 1

CMD ["/bin/bash"]
