just a draft, mainly for "personal" use

# How to use
## clone the project
> git clone https://github.com/arnaudbey/duplicate-domain.git

## make the script executable (from anywhere)
> cd duplicate-domain

> sudo cp duplicate_domain.sh /usr/bin/duplicate_domain

> sudo chmod +x /usr/bin/duplicate_domain

## launch it in your terminal with

> duplicate_domain

# what it does

copy a directory (a symfony2 one for example)

create a new db with a new user with privileges on it

duplicate a DB (certainly the one used by the directory copied) into the new one

clean logs/access.log and logs/error.log of the new dir

edit app/config/parameters.yml with the new db datas

duplicate and modify the site on /etc/apache2/sites-avaible and enable it (the site must have the same name as the dir) 

cache:clear and asset stuff