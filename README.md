# Prerequisites
- Tested on Windows 11 but should work on Windows 10 as well
- WSL2 installed: [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install)
- Ubuntu 20.04 installed on WSL
- Docker installed in Ubuntu per: `apt install docker.io docker-compose`
- Docker Windows desktop installed: [Docker Docs](https://docs.docker.com/desktop/windows/wsl/)
- dos2unix installed in Ubuntu

# Installation Instructions

## Initial Setup

1. To avoid later authentication and other issues ensure your `/etc/wsl.conf` has the configuration options in [wsl.conf](wsl.conf).
   - If it didn't and you updated the file:
     - close the Ubuntu Terminal
     - Open a Powershell with Admin rights
     - Type `wsl --terminate Ubuntu-20.04`; Your Ubuntu installation may have another name, so adjust if necessary
     - Also restart the Docker Desktop App (It should prompt you)
2. In order to work with an editor on Windows you can easily symlink the Windows home directory to your Ubuntu home directory with something
   like this:
   - `ln -s /mnt/c/User/<Your Windows Username>/<A directory you want to share>`
   - E.g. `ln -s /mnt/c/User/Joe\ Shmoe/my_repos`
3. Clone this repo or download the files into that location.
4. Make sure all files are in proper Unix file format. Use `dos2unix`.
   - E.g. `dos2unix Gemfile* *.sh Dockerfile *.yml`
5. Ensure user and group `postgres` exist with a UID of `999` in your Ubuntu WSL environment. Otherwise the postgres container will have issues creating the database. If it doesn't exist:
   - `sudo addgroup --gid 999 postgres`
   - `sudo adduser --no-create-home --uid 999 --gid 999 --disabled-password --disabled-login postgres`
   - `sudo vim /etc/passwd`
     - Change postgres user shell to: `/usr/sbin/nologin`

## Automated version

1. Follow the Initial Setup above
2. Run `./rails-app.sh --app-name new-app up`
   - This will create the necessary base images and install the containers properly as well as create a new app called "new-app" in the same sub-directory.
   - The script should get you all the way to both containers (web/rails and postgres) running.
3. Open a second terminal and run `./rails-app.sh --app-name new-app run rake db:create`
   - This will create the database for the new app.
4. Check [localhost:3000](http://localhost:3000)

The name of the app can be controlled via the `--app-name` parameter for `rails-app.sh`. This also allows for multiple apps to be kept in parallel as long as they all have a unique name. Non simultaneous operation of such apps has been tested, so a stack will only ever run for one of the 'apps'.

The app supports the following operations:
- `setup`: Just sets up a new application without starting the database.
- `update`: Recreate the web image with the Gemfile from the app that is specified.
- `up`: Runs the compose application. If the application doesn't exist a new one will be created (implied use of setup). Like `docker-compose up`
- `run`: Executes a command on the rails container. Like `docker-compose run ...`, eg. `rake db:create`
- `down`: Powers down the compose application. like `docker compose down`
- `clean`: Removes an app. Deletes the directory. Not recoverable!
- `clean-all`: Removes the app and the base image.  Not recoverable!

### Updating the gems for your Rails App

This repo has a predefined and small set of gems associated with the Rails Web container to be used with your Rails app. As you develop new gems may need to get added. Follow these instructions:
1. Modify the `Gemfile` in your app directory to add the gem you need.
2. Run Your app once to get the gem installed and verified as well as a new `Gemfile.lock` file created. Eg. `./rails-app.sh --app-name new-app up`
3. Now run `./rails-app.sh --app-name new-app update`. This will copy over the new `Gemfile` and `Gemfile.lock` files, delete the old rails-web image and create an updated version of it.
4. Run your Rails app normally. `./rails-app.sh --app-name new-app up`


## Manual Version

You don't need this if you use the automated version above!

1. Follow the Initial Setup above
2. Create an application directory. In this case we chose `/your_home/myapp`. Adjust [docker-compose.yml](docker-compose.yml) accordingly.
3. Copy [Gemfile](Gemfile) and [Gemfile.lock](Gemfile.lock) into that directory.
4. Make sure [Gemfile.lock](Gemfile.lock) is writable: `chmod a+w /your_home/myapp/Gemfile.lock`
5. Run `docker-compose run --rm --no-deps web rails new . --force --database=postgresql`
6. Run `sudo chown -R $USER:$USER /your_home/myapp`
7. Run `docker-compose build`
   - Note: There is a chance that the `bundle install` doesn't save all the installed gems in the container if the Gemfile doesn't have all the required gems in it. In that case manually update the container again:
     - `docker run -it -v /your_home/myapp:/myapp myapp_web /bin/bash`
     - `bundle check || bundle install --jobs 20 --retry 5`
     - `exit`
     - `docker tag myapp_web:latest myapp_web:old`
     - `docker container ls -a`
     - Note the ID of the last docker container
     - `docker commit <that container ID>`
     - `docker image ls`
     - Note the new Image ID
     - `docker tag <that image ID> myapp_web:latest`
8. Update `config/database.yml` with the [database.yml](database.yml)
9. Run `mkdir myapp/tmp/db`
10. Run `sudo chown -R postgres:postgres myapp/tmp/db`
11. Change `config.file_watcher = ActiveSupport::EventedFileUpdateChecker` to `config.file_watcher = ActiveSupport::FileUpdateChecker` in `/your_home/myapp/config/environments/development.rb`
    - This ensures the webview updates properly when there is a change
12. Run `docker-compose up`
13. In another terminal run: `docker-compose run --rm web rake db:create`
14. Check [localhost:3000](http://localhost:3000)

# Acknowledgements
- https://docs.docker.com/samples/rails/
- https://betterprogramming.pub/rails-6-development-with-docker-55437314a1ad
- https://hackernoon.com/installing-ruby-on-rails-6-on-ubuntu-a-how-to-guide-r8b732vn
- https://guides.rubyonrails.org/v6.0/getting_started.html

# Known issues
If you see errors like these:
- failed to solve: failed to solve with frontend dockerfile.v0: failed to create LLB definition: rpc error: code = Unknown desc = error getting credentials - err: exit status 1, out: \`\`
- /usr/bin/docker-credential-desktop.exe: Invalid argument

Please restart the Ubuntu Terminal. There seems to be an issue between WSL and Docker where the terminal 'forgets' how to be able to verify the docker login credentials. -> https://github.com/docker/for-win/issues/9061
