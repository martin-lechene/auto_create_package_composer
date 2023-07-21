#!/bin/bash

read -p "Entrez le nom du package (ex: votre-nom/mon-package-laravel): " package_name
read -p "Entrez la description du package: " package_description
read -p "Entrez votre nom: " author_name
read -p "Entrez votre adresse e-mail: " author_email

# Créer le répertoire pour le package
mkdir $package_name
cd $package_name

# Initialiser le dépôt Git
git init

# Créer le fichier composer.json
cat <<EOT >> composer.json
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
      "$(echo $author_name | tr '[:upper:]' '[:lower:]')\\\\$(echo $package_name | tr '[:upper:]' '[:lower:]')\\\\": "src/"
    }
  }
}
EOT

# Créer la structure du package
mkdir src

# Ajouter le fichier initial pour le package (facultatif)
# Vous pouvez ajouter ici les fichiers nécessaires pour votre package

# Ajouter les fichiers au dépôt Git et effectuer le premier commit
git add .
git commit -m "Initial commit"

echo "Package Composer créé avec succès!"
