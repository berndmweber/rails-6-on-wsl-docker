# Prerequisistes
- Tested on Windows 11 but should work on Windows 10 as well
- WSL2 installed: [Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install)
- Ubuntu 20.04 installed on WSL
- Docker installed in Ubuntu per: `apt install docker.io docker-compose`
- Docker Windows desktop installed: [Docker Docs](https://docs.docker.com/desktop/windows/wsl/)

# Installation Instructions

1. To avoid later aithentication and other issues ensure your `/etc/wsl.conf` has the configuration options in [wsl.conf](wsl.conf).
   - If it didn't and you updated the file:
     - close the Ubuntu Terminal
     - Open a Powershell with Admin rights
     - Type `wsl --terminate Ubuntu-20.04`; Your Ubuntu installation may have another name, so adjust if necessary
     - Also restart the Docker Desktop App (It should prompt you)
2. Clone this repo or download the files.
3. Create an application directory. In this case we chose `/your_home/myapp`. Adjust [docker-compose.yml](docker-compose.yml) accordingly.
4. Copy [Gemfile](Gemfile) and [Gemfile.lock](Gemfile.lock) into that directory.
5. Make sure [Gemfile.lock](Gemfile.lock) is writable: `chmod a+w Gemfile.lock`
6. Run `docker-compose run --no-deps web rails new . --force --database=postgresql`
7. Run `sudo chown -R $USER:$USER /your_home/myapp`
8. Run `docker-compose build`
9. Update `config/database.yml` with the [database.yml](database.yml)
10. Ensure user and group `postgres` exist in your Ubuntu WSL environment. Otherwise:
	  - `sudo addgroup --gid 999 postgres`
	  - `sudo adduser --no-create-home --uid 999 --gid 999 --disabled-password --disabled-login postgres`
	  - `sudo vim /etc/password`
		  - Change postgres user shell to: `/usr/sbin/nologin`
11. Run `mkdir myapp/tmp/db’`
12. Run `chown -R postgres:postgres tmp/db/`
13. Run `docker-compose up`
14. In another terminal run: `docker-compose run web rake db:create`
15. Check [localhost:3000’](localhost:3000’)
