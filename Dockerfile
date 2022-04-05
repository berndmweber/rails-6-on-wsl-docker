FROM ruby:latest

ENV APP_PATH /myapp
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000

RUN apt update && apt install -y curl git nodejs npm gcc make libssl-dev libreadline-dev zlib1g-dev g++ libpq-dev postgresql-client

# RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list
# RUN apt update && apt install -y yarn
RUN npm install --global yarn
RUN yarn install --check-files

# navigate to app directory
WORKDIR $APP_PATH

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE $RAILS_PORT

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]