# Use phusion/passenger-full as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/passenger-customizable:1.0.12
# Or, instead of the 'full' variant, use one of these:
#FROM phusion/passenger-ruby23:<VERSION>
#FROM phusion/passenger-ruby24:<VERSION>
#FROM phusion/passenger-ruby25:<VERSION>
#FROM phusion/passenger-ruby26:<VERSION>
#FROM phusion/passenger-jruby92:<VERSION>
#FROM phusion/passenger-nodejs:<VERSION>
#FROM phusion/passenger-customizable:<VERSION>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# for Openturns
RUN apt-get update -y \
	&& apt-get install -y libsm6 libxext6

# Thrift
ENV THRIFT_VERSION 0.13.0

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

# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features.
#
# N.B. these images are based on https://github.com/phusion/baseimage-docker,
# so anything it provides is also automatically on board in the images below
# (e.g. older versions of Ruby, Node, Python).
#
# Uncomment the features you want:
#
#   Ruby support
#RUN /pd_build/ruby-2.3.*.sh
#RUN /pd_build/ruby-2.4.*.sh
# RUN /pd_build/ruby-2.5.*.sh \
# 	&& bash -lc 'rvm install ruby-2.5.3' \
# 	&& bash -lc 'rvm --default use ruby-2.5.3'
#RUN /pd_build/ruby-2.6.*.sh
#RUN /pd_build/jruby-9.2.*.sh
#   Python support.
RUN /pd_build/python.sh \
	&& ln -sf /usr/bin/python3.8 /usr/bin/python
RUN apt-get install -y python3.8-dev python3-distutils

#   Node.js and Meteor standalone support.
#   (not needed if you already have the above Ruby support)
RUN /pd_build/nodejs.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# yarn install
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH /root/.yarn/bin:$PATH

# pip install
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
	&& python3 get-pip.py

RUN pip install numpy \
	&& pip install cython \
	&& pip install openmdao \
	&& pip install salib \
	&& pip install smt \
	&& pip install openturns \
	&& pip install thrift \
	&& pip install wop

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /whatsopt 
WORKDIR /whatsopt

COPY Gemfile Gemfile.lock ./ 

RUN bundle config without staging production \
	&& bundle install --jobs 20 --retry 5

COPY . ./

RUN pip install -e services/whatsopt_server/optimizer_store/oneramdao/doe \
	&& pip install -e services/whatsopt_server/optimizer_store/oneramdao/kpls \
	&& pip install -e services/whatsopt_server/optimizer_store/oneramdao/mfk \
	&& pip install -e services/whatsopt_server/optimizer_store/oneramdao/moe \
	&& pip install -e services/whatsopt_server/optimizer_store/oneramdao/sego \
	&& pip install -e services

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

