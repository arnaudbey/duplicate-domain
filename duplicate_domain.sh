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


printIt "Répertoires disponibles"
ls -al | grep ^d | awk '{print $9}'

$sourceDir = ""
while [ ! -d "$sourceDir" ]; do
    echo "le répertoire n'existe pas..."
    read -p 'répertoire à copier ? : ' sourceDir
done

read -p 'nom du nouveau domaine ? : ' targetDir
while [ -d "$targetDir" ]; do
    echo "le répertoire existe déjà"
    read -p 'nom du nouveau domaine ? : ' targetDir
done
printIt "copie en cours..."
sudo cp -ipdR ${sourceDir} ${targetDir}
printIt "repertoire ${sourceDir} copié vers ${targetDir}"

read -p 'User du compte root mysql : ' msqlRootUser
read -p 'Password du compte root mysql : ' msqlRootPasswd
read -p 'Nom de la nouvelle base à créer ? : ' newDB
mysql --user="${msqlRootUser}" --password="${msqlRootPasswd}" --execute="CREATE DATABASE ${newDB};"
printIt "Base ${newDB} créée"


read -p 'Login du nouvel utilisateur mysql : ' loginNewUser
read -p 'Password du nouvel utilisateur mysql : ' passwdNewUser
mysql --user="${msqlRootUser}" --password="${msqlRootPasswd}" --execute="grant usage on *.* to ${loginNewUser}@localhost identified by '${passwdNewUser}';"
printIt "Utilisateur ${loginNewUser} créé"
mysql --user="${msqlRootUser}" --password="${msqlRootPasswd}" --execute="grant all privileges on ${newDB}.* to ${loginNewUser}@localhost ;"
printIt " ${loginNewUser} a maintenant les droits sur la base ${newDB}"

read -p 'Nom de la DB qui sera copiée : ' oldDB
mysqldump -u ${msqlRootUser} -p${msqlRootPasswd} ${oldDB} | mysql -u ${msqlRootUser} -p${msqlRootPasswd} ${newDB}
printIt "Base ${oldDB} dupliquée vers ${newDB}"


if [ -f "$targetDir"/logs/access.log ]; then
    sudo :> ${targetDir}/logs/access.log
    sudo :> ${targetDir}/logs/error.log
    printIt "Logs vidés"
fi

if [ -f "$targetDir"/app/config/parameters.yml ]; then
    sudo sed -i -e 's/database_name.*$/database_name : '${newDB}'/g' ${targetDir}/app/config/parameters.yml
    sudo sed -i -e 's/database_user.*$/database_user : '${loginNewUser}'/g' ${targetDir}/app/config/parameters.yml
    sudo sed -i -e 's/database_password.*$/database_password : '${passwdNewUser}'/g' ${targetDir}/app/config/parameters.yml

    printIt "${targetDir}/app/config/parameters.yml modifié"
else
    printIt "${sourceDir}/app/config/parameters.yml non trouvé"
fi

if [ -f /etc/apache2/sites-available/"$sourceDir" ]; then
    sudo cp -ip /etc/apache2/sites-available/${sourceDir} /etc/apache2/sites-available/${targetDir}
    sudo sed -i -e 's/'${sourceDir}'/'${targetDir}'/g' /etc/apache2/sites-available/${targetDir}
    sudo ln -s /etc/apache2/sites-available/${targetDir} /etc/apache2/sites-enabled/${targetDir}

    printIt "/etc/apache2/sites-available/${targetDir}"
else
    printIt "/etc/apache2/sites-available/${sourceDir} non trouvé"
fi

if [ -d "$sourceDir"/app/config/ ]; then
    cd ${targetDir}
    php app/console cache:clear --no-debug
    php app/console assetic:dump --no-debug
    php app/console assets:install --symlink --no-debug
    printIt "Cache vidé, assetic dump et assets install (dev)"
    php app/console cache:clear --env=prod --no-debug
    php app/console assetic:dump --env=prod --no-debug
    php app/console assets:install --symlink --env=prod --no-debug
    printIt "Cache vidé, assetic dump et assets install (prod)"
fi

printIt "!!!!!!!!!!!!!!!  PENSER AU CACHE APC !!!!!!!!!!!!!!!"
printIt "!!!!!!!!!!!!!!!  PENSER AU CACHE APC !!!!!!!!!!!!!!!"
printIt "!!!!!!!!!!!!!!!  PENSER AU CACHE APC !!!!!!!!!!!!!!!"


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