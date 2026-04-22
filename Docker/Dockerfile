FROM ruby:3.3-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY config.ru puma.rb ./

RUN mkdir -p /geminabox-data

VOLUME /geminabox-data

EXPOSE 9292

CMD ["bundle", "exec", "puma", "-C", "puma.rb"]
