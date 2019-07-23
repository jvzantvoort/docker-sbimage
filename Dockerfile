FROM python:3.6

LABEL \
  maintainer="john@vanzantvoort.org" \
  description="site builder image"

# add the python requirements file
ADD requirements.txt /tmp/requirements.txt
ADD puppet-pygments-lexer-0.0.1.tar.gz /tmp

# install required debian packages and
# run pip to install the requirements
RUN apt-get update && apt-get install -y libldap2-dev libsasl2-dev rsync && \
pip install -r /tmp/requirements.txt && \
sed -i 's,sphinx.application,sphinx.errors,g' /usr/local/lib/python3.6/site-packages/sphinxcontrib/googleanalytics.py
RUN cd /tmp/puppet-pygments-lexer-0.0.1; \
    python setup.py install; \
    cd /tmp

WORKDIR /code
VOLUME ["/webroot"]
VOLUME ["/output"]

CMD ["/bin/bash"]
