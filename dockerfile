FROM ruby:2.7.2-alpine3.13
USER root
RUN apk add --no-cache build-base

ADD . /app
WORKDIR /app
# COPY Gemfile /app
# COPY Gemfile.lock /app/
RUN bundle install

RUN echo $(pwd)
RUN echo $(ls)

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
# ["bundle", "exec", "rackup"]
# ["ruby", "./search_api/app.rb"]
# ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
# 
