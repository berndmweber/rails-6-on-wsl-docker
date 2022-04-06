FROM ruby:3.1.1

ENV APP_PATH /rails_app
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000

RUN apt update && apt install -y curl git nodejs npm postgresql-client

# Install Yarn
RUN npm install --global yarn
RUN yarn install --check-files

# navigate to app directory
WORKDIR $APP_PATH

# Install Rails app
COPY Gemfile $APP_PATH/Gemfile
COPY Gemfile.lock $APP_PATH/Gemfile.lock
RUN bundle check || bundle install --jobs 20 --retry 5

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE $RAILS_PORT

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
