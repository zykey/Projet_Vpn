#!/bin/bash

# Installation d'OpenVPN
sudo apt update
sudo apt install openvpn -y

# Demande du nombre d'utilisateurs à créer
read -p "Combien d'utilisateurs souhaitez-vous créer ? " num_users

# Boucle pour créer les utilisateurs
for ((i=1; i<=num_users; i++))
do
    read -p "Nom d'utilisateur pour l'utilisateur $i : " username
    read -p "Mot de passe pour l'utilisateur $i : " password

    # Création de l'utilisateur avec le nom et le mot de passe fournis
    sudo bash -c "cd /etc/openvpn/easy-rsa/ && ./easyrsa build-client-full $username nopass"

    # Création du fichier de configuration pour l'utilisateur
    sudo cp /etc/openvpn/client.conf "/etc/openvpn/$username.ovpn"

    # Ajout des clés et des certificats dans le fichier de configuration de l'utilisateur
    echo "<ca>" | sudo tee -a "/etc/openvpn/$username.ovpn"
    sudo cat /etc/openvpn/easy-rsa/pki/ca.crt | sudo tee -a "/etc/openvpn/$username.ovpn"
    echo "</ca>" | sudo tee -a "/etc/openvpn/$username.ovpn"

    echo "<cert>" | sudo tee -a "/etc/openvpn/$username.ovpn"
    sudo cat "/etc/openvpn/easy-rsa/pki/issued/$username.crt" | sudo tee -a "/etc/openvpn/$username.ovpn"
    echo "</cert>" | sudo tee -a "/etc/openvpn/$username.ovpn"

    echo "<key>" | sudo tee -a "/etc/openvpn/$username.ovpn"
    sudo cat "/etc/openvpn/easy-rsa/pki/private/$username.key" | sudo tee -a "/etc/openvpn/$username.ovpn"
    echo "</key>" | sudo tee -a "/etc/openvpn/$username.ovpn"

    # Réglage des permissions
    sudo chmod 600 "/etc/openvpn/$username.ovpn"

    echo "L'utilisateur $username a été créé avec succès."
    echo "Le fichier de configuration pour l'utilisateur est disponible à l'emplacement suivant :"
    echo "/etc/openvpn/$username.ovpn"
done
