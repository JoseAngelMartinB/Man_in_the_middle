#!/bin/bash

# Man in the middle attack
# https://github.com/JoseAngelMartinB/Man_in_the_middle
# Autores:
#  - José Ángel Martín Baos
#  - Óscar Pérez Galán

#Busqueda en cache ARP por direcciones duplicadas
while :
do
duplicado=$(arp -a | awk '{print $4 " "}' | grep [0-9] | sort | uniq -c | grep -o " [2:*] ")

        if [ ! -z $duplicado]
        then
                zenity --error --text "Esta sufriendo un ataque de ARP SPOOFING"

        fi

sleep 60
nmap -sP 192.168.1.1-254 > /dev/null
done
