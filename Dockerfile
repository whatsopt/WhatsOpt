FROM ruby:2.3
MAINTAINER remi.lafage@inera.fr

RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  python2.7 \
  python-pip \
  python-dev \
  nodejs
RUN pip install --upgrade pip
RUN pip install jupyter
  
RUN mkdir -p /whatsopt 
WORKDIR /whatsopt

COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . ./

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]