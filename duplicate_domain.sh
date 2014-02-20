#!/bin/bash
printIt () {
    echo "##########";
    echo "###### "$1
    echo "##########";
}

clear
echo "
    ,@;@,                                   ,@;@, 
   ;@;@( \@;@;@;@;@;@,         ,@;@;@;@;@;@/ )@;@; 
   /a \`@\_|@;@;@;@;@;@;,     ,;@;@;@;@;@;@|_/@' e\ 
  /    )@:@;@;@;@/@:@;@|)   (|@;@:@\@;@;@;@:@(    \ 
  \`--''\`;@;@;@;@|@;@;@\`       '@;@;@|@;@;@;@;'\`'
        \`;@;\;@;\;@;@\`o        '@;@;/;@;/;@;' 
          || |   \\ (           ) //   | || 
          || |   // /  o        \ \\   | || 
          // (  // /             \ \\  ) \\ 
                        
----------------------------------------------------------
            Duplicate a domain (for sheeps)
----------------------------------------------------------
"

printIt "Available directories"
ls -al | grep ^d | awk '{print $9}'

read -p 'Dir to copy : ' sourceDir
while [ ! -d "$sourceDir" ]; do
    echo "This dir does not exist"
    read -p 'Dir to copy : ' sourceDir
done

read -p 'Name of the new dir : ' targetDir
while [ -d "$targetDir" ]; do
    echo "This dir already exists"
    read -p 'Name of the new dir : ' targetDir
done
printIt "copying... "
sudo cp -ipdR ${sourceDir} ${targetDir}
printIt "dir ${sourceDir}/ copied into ${targetDir}/"

read -p 'mysql root login : ' msqlRootUser
read -p 'mysql root password : ' msqlRootPasswd
read -p 'Name of the new DB ? : ' newDB
mysql --user="${msqlRootUser}" --password="${msqlRootPasswd}" --execute="CREATE DATABASE ${newDB};"
printIt "DB ${newDB} created"


read -p 'Login new mysql user : ' loginNewUser
read -p 'Password new mysql user : ' passwdNewUser
mysql --user="${msqlRootUser}" --password="${msqlRootPasswd}" --execute="grant usage on *.* to ${loginNewUser}@localhost identified by '${passwdNewUser}';"
printIt "User ${loginNewUser} created"
mysql --user="${msqlRootUser}" --password="${msqlRootPasswd}" --execute="grant all privileges on ${newDB}.* to ${loginNewUser}@localhost ;"
printIt " ${loginNewUser} has now full rights on ${newDB}"

read -p 'Name of the source DB (the one who has to be copied) : ' oldDB
mysqldump -u ${msqlRootUser} -p${msqlRootPasswd} ${oldDB} | mysql -u ${msqlRootUser} -p${msqlRootPasswd} ${newDB}
printIt "DB ${oldDB} duplicated into ${newDB}"


if [ -f "$targetDir"/logs/access.log ]; then
    sudo :> ${targetDir}/logs/access.log
    sudo :> ${targetDir}/logs/error.log
    printIt "logs cleaned"
fi

if [ -f "$targetDir"/app/config/parameters.yml ]; then
    sudo sed -i -e 's/database_name.*$/database_name : '${newDB}'/g' ${targetDir}/app/config/parameters.yml
    sudo sed -i -e 's/database_user.*$/database_user : '${loginNewUser}'/g' ${targetDir}/app/config/parameters.yml
    sudo sed -i -e 's/database_password.*$/database_password : '${passwdNewUser}'/g' ${targetDir}/app/config/parameters.yml

    printIt "${targetDir}/app/config/parameters.yml modified"
else
    printIt "${sourceDir}/app/config/parameters.yml not found"
fi

if [ -f /etc/apache2/sites-available/"$sourceDir" ]; then
    sudo cp -ip /etc/apache2/sites-available/${sourceDir} /etc/apache2/sites-available/${targetDir}
    sudo sed -i -e 's/'${sourceDir}'/'${targetDir}'/g' /etc/apache2/sites-available/${targetDir}
    sudo ln -s /etc/apache2/sites-available/${targetDir} /etc/apache2/sites-enabled/${targetDir}

    printIt "/etc/apache2/sites-available/${targetDir} created"
else
    printIt "/etc/apache2/sites-available/${sourceDir} not found"
fi

if [ -d "$sourceDir"/app/config/ ]; then
    cd ${targetDir}
    php app/console cache:clear --no-debug
    php app/console assetic:dump --no-debug
    php app/console assets:install --symlink --no-debug
    printIt "cache clear, assetic dump and assets install (dev)"
    php app/console cache:clear --env=prod --no-debug
    php app/console assetic:dump --env=prod --no-debug
    php app/console assets:install --symlink --env=prod --no-debug
    printIt "cache clear, assetic dump and assets install (prod)"
fi

printIt "!!!!!!!!!!!!!!!  And what about APC ? !!!!!!!!!!!!!!!"


echo "
    ,@;@,                                   ,@;@, 
   ;@;@( \@;@;@;@;@;@,         ,@;@;@;@;@;@/ )@;@; 
   /a \`@\_|@;@;@;@;@;@;,     ,;@;@;@;@;@;@|_/@' e\ 
  /    )@:@;@;@;@/@:@;@|)   (|@;@:@\@;@;@;@:@(    \ 
  \`--''\`;@;@;@;@|@;@;@\`       '@;@;@|@;@;@;@;'\`'
        \`;@;\;@;\;@;@\`o        '@;@;/;@;/;@;' 
          || |   \\ (           ) //   | || 
          || |   // /  o o    \ \\   | || 
          // (  // /  oooooo     \ \\  ) \\ 
                     ooooooooo 
                 ooo oo oooo ooo oooooo 
                  oooooo ooo ooooooo oo
----------------------------------------------------------
            Duplicate a domain (for SHITTY sheeps)
----------------------------------------------------------
"