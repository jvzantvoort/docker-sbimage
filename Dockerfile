FROM python:2.7.13

LABEL \
  maintainer="john@vanzantvoort.org" \
  description="site builder production image"

# add the python requirements file
ADD requirements.txt /tmp/requirements.txt

# install required debian packages
RUN apt-get update && apt-get install -y libldap2-dev libsasl2-dev

# Run pip to install the requirements
RUN pip install -r /tmp/requirements.txt

WORKDIR /code
VOLUME ["/webroot"]
VOLUME ["/output"]

CMD ["/bin/bash"]