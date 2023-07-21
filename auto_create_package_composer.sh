#!/bin/bash

######################################
# Script de création de package Laravel
# Auteur: Martin Lechêne (doganddev.eu / martinlechene.com)
# Date de création: 23.07.2023
# Disponible sur: https://doganddev.eu/scripts/auto-create-package-composer
######################################

# Récupérer le nom du dossier courant pour le package
current_directory=$(basename "$PWD")

# Vérifier si un composer.json existe déjà
if [ -f "composer.json" ] && [ -s "composer.json" ]; then
    echo "Un fichier composer.json existe déjà et n'est pas vide. Le script s'arrête."
    exit 1
fi

# Proposer des valeurs par défaut
default_description="https://doganddev.eu/packages/$current_directory"
default_author_name="doganddev"
default_author_email="contact@doganddev.eu"

# Demander les informations pour le package
echo "========== Informations pour le package =========="
read -p "Entrez le nom du package (ex: votre-nom/mon-package-laravel) [$current_directory]: " package_name
package_name=${package_name:-"$USER/$current_directory"}

read -p "Entrez la description du package [$default_description]: " package_description
package_description=${package_description:-"$default_description"}

read -p "Entrez votre nom [$default_author_name]: " author_name
author_name=${author_name:-"$default_author_name"}

read -p "Entrez votre adresse e-mail [$default_author_email]: " author_email
author_email=${author_email:-"$default_author_email"}

# Corriger le nom d'auteur pour le namespace
author_namespace=$(echo "$author_name" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

# Demander si on veut ajouter un exemple et un test
echo "========== Options supplémentaires =========="
read -p "Voulez-vous ajouter un exemple et un test? (Oui/Non) [Oui]: " add_example_test
add_example_test=${add_example_test:-"Oui"}

# Créer le répertoire pour le package s'il n'existe pas
mkdir -p "$package_name"
cd "$package_name"

# Initialiser le dépôt Git s'il n'existe pas
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git init
fi

# Créer le fichier composer.json s'il n'existe pas
if [ ! -f "composer.json" ]; then
    cat <<EOT > composer.json
{
  "name": "$package_name",
  "description": "$package_description",
  "type": "library",
  "license": "MIT",
  "authors": [
    {
      "name": "$author_name",
      "email": "$author_email"
    }
  ],
  "autoload": {
    "psr-4": {
      "$author_namespace\\\\$current_directory\\\\": "src/"
    }
  }
}
EOT
fi

# Créer la structure du package
mkdir -p src

# Ajouter un exemple et un test si demandé
if [[ $add_example_test =~ ^[OoYy]$ ]]; then
    echo "<?php" > src/Example.php
    echo "namespace $author_namespace\\$current_directory;" >> src/Example.php
    echo "" >> src/Example.php
    echo "class Example" >> src/Example.php
    echo "{" >> src/Example.php
    echo "    public function sayHello()" >> src/Example.php
    echo "    {" >> src/Example.php
    echo "        return 'Hello, this is your package!';" >> src/Example.php
    echo "    }" >> src/Example.php
    echo "}" >> src/Example.php

    # Ajouter le fichier initial pour le package (facultatif)
    # Vous pouvez ajouter ici les fichiers nécessaires pour votre package

    # Exemple d'utilisation du package
    echo "Exemple d'utilisation du package :"
    cat <<EOT > test.php
<?php

require 'vendor/autoload.php';

\$example = new $author_namespace\\$current_directory\\Example();
echo \$example->sayHello() . PHP_EOL;
EOT

    # Installer les dépendances avec Composer
    composer install

    # Exécuter le script de test
    echo "Résultat du test :"
    time php test.php
fi

# Proposer de créer un dépôt Git à distance
echo "========== Git Remote =========="
read -p "Voulez-vous créer un dépôt Git à distance pour ce package? (Oui/Non): " create_remote_repo
if [[ $create_remote_repo =~ ^[OoYy]$ ]]; then
    read -p "Entrez l'URL du dépôt Git à distance (ex: git@github.com:votre-nom/mon-package-laravel.git): " remote_repo_url
    git remote add origin "$remote_repo_url"
    git push -u origin master
fi

# Proposer de transférer le package sur votre site doganddev.eu
echo "========== Transfert sur votre serveur web =========="
read -p "Voulez-vous transférer le package sur votre serveur web doganddev.eu? (Oui/Non): " transfer_to_server
if [[ $transfer_to_server =~ ^[OoYy]$ ]]; then
    echo "Choisissez le mode de transfert (FTP, SSH, etc.) :"
    echo "1. FTP"
    echo "2. SSH"
    # Ajoutez d'autres options de transfert si nécessaire

    read -p "Entrez le numéro du mode de transfert : " transfer_mode
    case $transfer_mode in
        1)
            echo "Transfert en mode FTP"
            # Demander les informations FTP pour le transfert
            read -p "Entrez le nom d'utilisateur FTP pour le transfert : " ftp_username
            read -p "Entrez le mot de passe FTP pour le transfert : " ftp_password
            ftp_host="votre-hote-ftp.com" # Remplacez par l'hôte FTP de votre serveur
            ftp_dir="/chemin/vers/votre/dossier/" # Remplacez par le chemin du dossier où vous voulez transférer le package sur le serveur

            echo "Vous pouvez exécuter la commande FTP suivante dans votre terminal :"
            echo "ftp -n $ftp_host <<END_SCRIPT
quote USER $ftp_username
quote PASS $ftp_password
binary
lcd $PWD
cd $ftp_dir
put -r $package_name
quit
END_SCRIPT"
            ;;
        2)
            echo "Transfert en mode SSH"
            # Demander les informations SSH pour le transfert
            read -p "Entrez l'adresse SSH de votre serveur : " ssh_address
            read -p "Entrez le nom d'utilisateur SSH pour le transfert : " ssh_username
            ssh_dir="/chemin/vers/votre/dossier/" # Remplacez par le chemin du dossier où vous voulez transférer le package sur le serveur

            echo "Vous pouvez exécuter la commande SCP suivante dans votre terminal :"
            echo "scp -r $PWD/$package_name $ssh_username@$ssh_address:$ssh_dir"
            ;;
        *)
            echo "Option de transfert non reconnue. Le transfert est annulé."
            ;;
    esac
fi

echo "Package Composer créé avec succès!"
