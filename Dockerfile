FROM ubuntu:16.04
MAINTAINER remi.lafage@onera.fr

#ENV http_proxy=http://proxy.onecert.fr:80
#ENV https_proxy=http://proxy.onecert.fr:80

# adapted from drecom/ubuntu-base drecom/ubuntu-ruby
RUN apt-get update \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    wget \
    curl \
    git \
    build-essential \
    vim \
    dtach \
    imagemagick \
    libmagick++-dev \
    libqtwebkit-dev \
    libffi-dev \
    mysql-client \
    libmysqlclient-dev \
    libxslt1-dev \
    redis-tools \
    xvfb \
    python \
	python-dev \
    tzdata \
	libyaml-dev \
	libsqlite3-dev \
	sqlite3 \
	libxml2-dev \
	libcurl4-openssl-dev \
	python-software-properties \
	python-pip \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# node.js LTS install
RUN curl --silent --location https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    && npm -g up

# yarn install
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# pip install
#RUN wget https://bootstrap.pypa.io/get-pip.py \
#&&  python get-pip.py

# Ruby
RUN git clone git://github.com/rbenv/rbenv.git /usr/local/rbenv \
&&  git clone git://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
&&  git clone git://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
&&  /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
&&  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
&&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
&&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

RUN eval "$(rbenv init -)"; rbenv install 2.3.3 \
&&  eval "$(rbenv init -)"; rbenv global 2.3.3 \
&&  eval "$(rbenv init -)"; gem update --system \
&& eval "$(rbenv init -)"; gem install bundler --force

# pip install
RUN pip install jupyter \
    && pip install thrift==0.11.0 \
	&& pip install openmdao==2.2.1

# OpenVSP
#RUN apt-get install -y git cmake libxml2-dev \
#			g++ libcpptest-dev libeigen3-dev \
#			libcminpack-dev swig \
#  && apt-get update \
#  && mkdir OpenVSP \
#  && cd OpenVSP \
#  && mkdir repo \
#  && git clone https://github.com/OpenVSP/OpenVSP.git repo \
#  && mkdir build \
#  && cd build \
#  && echo $PWD \
#  && cmake -DCMAKE_BUILD_TYPE=Release \
#	-DVSP_USE_SYSTEM_CPPTEST=false \
#	-DVSP_USE_SYSTEM_LIBXML2=true \
#	-DVSP_USE_SYSTEM_EIGEN=false \
#	-DVSP_USE_SYSTEM_CMINPACK=true \
#	-DCMAKE_INSTALL_PREFIX=/usr/local/bin \
#	-DVSP_NO_GRAPHICS=1 ../repo/SuperProject \
#  && make 

# Thrift
ENV THRIFT_VERSION 0.11.0

RUN buildDeps=" \
		automake \
		bison \
		curl \
		flex \
		g++ \
		libboost-dev \
		libboost-filesystem-dev \
		libboost-program-options-dev \
		libboost-system-dev \
		libboost-test-dev \
		libevent-dev \
		libssl-dev \
		libtool \
		make \
		pkg-config \
	"; \
	apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& curl -sSL "http://apache.mirrors.spacedump.net/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz" -o thrift.tar.gz \
	&& mkdir -p /thrift \
	&& tar zxf thrift.tar.gz -C /thrift --strip-components=1 \
	&& rm thrift.tar.gz \
	&& cd /thrift \
	&& ./configure  --without-python --without-cpp --without-ruby --without-nodejs --without-py3 \
	&& make \
	&& make install \
	&& cd / \
    && rm -rf /thrift 

RUN mkdir -p /whatsopt 
WORKDIR /whatsopt

COPY Gemfile Gemfile.lock ./ 
RUN bundle install --jobs 20 --retry 5

COPY . ./

EXPOSE 3000
EXPOSE 3035

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]