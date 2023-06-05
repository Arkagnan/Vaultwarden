#!/bin/bash

# Auteur : Esteban DEBOVE
# Date : 28/12/2022
# Fonction : Script permettant l'automatisation de l'installation et la configuration de Vaultwarden

#########################################
#########################################

#############################
# Préparation du background #
#############################

# Stockage de l'adresse IP dans une variable et suppression des zéro
IP_Addr=$(/usr/bin/hostname -I | sed 's/\ //g')

##############################################
# Initialisation avant création du conteneur #
##############################################

# Création du fichier de stockage du futur conteneur en local
/usr/bin/mkdir /home/rocky/vw-data 2>>/tmp/debug.err

# Génération d'un password pour la future interface admin (clé 128bits)
mdp=$(/usr/bin/openssl rand -base64 16) 2>>/tmp/debug.err

# Création du répertoire des services systemd sous le user rocky
/usr/bin/mkdir -p /home/rocky/.config/systemd/user 2>>/tmp/debug.err

##########################################################
# Installation et configuration du conteneur Vaultwarden #
##########################################################

# Création du conteneur avec les arguments
/usr/bin/podman run -d --name vaultwarden -v /home/rocky/vw-data/:/data/:Z -e ROCKET_PORT=8080 -e ADMIN_TOKEN=$mdp -p 8080:8080 docker.io/vaultwarden/server:latest 2>>/tmp/debug.err

# Génération du service vaultwarden et rangement dans le répertoire systemd de rocky
/usr/bin/podman generate systemd --name vaultwarden > /home/rocky/.config/systemd/user/container-vaultwarden.service 2>>/tmp/debug.err

# Démarrage du service vaultwarden
/usr/bin/systemctl --user start container-vaultwarden 2>>/tmp/debug.err

# Execution du service vaultwarden au démarrage de l'instance
/usr/bin/systemctl --user enable container-vaultwarden 2>>/tmp/debug.err

# Lancement des processus sans logon de l'utilisateur
/usr/bin/loginctl enable-linger rocky

# Affichage des status du conteneur
/usr/bin/podman ps 2>>/tmp/debug.err
/usr/bin/echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
/usr/bin/echo "-----------------------------------------------------------"
/usr/bin/systemctl --user status container-vaultwarden 2>>/tmp/debug.err

#########################
# Affichage utilisateur #
#########################

/usr/bin/echo -e "\n\n"
/usr/bin/echo "==================================="
/usr/bin/echo "= Welcome on Vaultwarden by Alize ="
/usr/bin/echo "==================================="
/usr/bin/echo -e "\n"
/usr/bin/echo "You are been connected on rocky !"
/usr/bin/echo "Your IP adress : $IP_Addr"
/usr/bin/echo "User interface access url : $IP_Addr:8080/#/login"
/usr/bin/echo "---------------------------------------------------"
/usr/bin/echo "---------------------------------------------------"
/usr/bin/echo "Admin interface access url : $IP_Addr:8080/admin"
/usr/bin/echo "Admin token : $mdp"
/usr/bin/echo -e "\n\n"
