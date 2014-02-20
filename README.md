just a draft, mainly for "personal" use

# what it does

copy a directory (a symfony2 one for example)

create a new db with a new user with privileges on it

duplicate a base (certainly the one used by the directory copied) into the new one

clean logs/access.log and logs/error.log of the new dir

edit app/config/parameters.yml with the new db datas

duplicate and modify the site on /etc/apache2/sites-avaible and enable it (the site must have the same name as the dir) 

cache:clear and asset stuff

# use
clone this repo

copy the .sh file to /var/www/ or cd ~/htdocs or ....

cd /var/www/ or cd ~/htdocs or ....

sh ./duplicate_domain.sh

(and maybe restart apache)

#enjoy
