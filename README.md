# Man in the middle attack
Este repositorio contiene todos los scripts y tutoriales necesarios para llevar acabo un ataque 'man in the middle'.



## Configuración del entrono de pruevas usando Vagrant
Para poder seguir los pasos descritos aquí, el primer requisito será descargar el repositorio en el ordenador. Para ello, debemos contar con la herramienta git. Una vez dispongamos de ella, podemos proceder a clonar el repositorio mediante el comando:
```
$ git clone https://github.com/JoseAngelMartinB/Man_in_the_middle.git
```

Para llevar a cabo la demostración del ataque, vamos a utilizar diversas máquinas virtuales. Dado que la configuración de dichas máquinas puede resultar compleja para un usuario novel, se ha decidido usar la herramienta Vagrant para crear y configurar el entorno. Por lo tanto, será necesario instalar dicho sofware, que puede ser descargado desde su [página oficial](https://www.vagrantup.com/).

Una vez descargado Vagrant, desde el directorio base del repositorio, ejecutamos el siguiente comando:
```
$ vagrant up
```

Mediante este comando Vagrant comenzará a descargar, montar y provisionar las distintas máquinas virtuales necesarias para la realización de esta demostración del ataque. Una vez vagrant ha terminado, dispondremos de 3 máquinas virtuales corriendo en nuestra máquina anfitrión. Una de ellas (la máquina victima) dispone de entorno gráfico que es lanzado al ejecutar el comando anterior, sin embargo, las otras dos máquinas (router y atacante), no tienen entorno gráfico y deben ser accedidas usando ssh. Por ejemplo, para acceder a la máquina atacante, se ejecutará el siguiente comando:
```
$ vagrant ssh atacante
```

Una vez realizado los pasos anteriores tendremos el entorno de trabajo montado y configurado. A partir de este momento, solo vamos a trabajar usando la máquina victima (desde la interfaz gráfica) y la máquina atacante (desde la consola mediante conexión ssh).





## Descarga e instalación de las herramientas necesarias
Para poder realizar el ataque, es necesario instalar algunas herramientas en la máquina atacante. El uso de estas herramientas serán explicadas posteriormente. La primera de ellas será *arpspoof*, que nos permitirá realizar el ataque "man in the middle" propiamente dicho, mediante la falsifiación de paquetes ARP. La siguiente herramienta será "iptables", que es un firewall de filtrado de paquetes del kernel de Linux (por lo que no será necesario instalarla). También se necesiará la herramienta "SSLSTrip", la cual va a permitir convertir todo el HTTPS de una web en HTTP (sin cifrar) y por tanto engañar a la victima, para obtener sus datos. Estos programás serán instalados usando lo siguientes comandos en la máquina atacante:
```
$ sudo apt-get update
$ sudo apt-get install dsniff sslstrip 
```

Por último será necesario descargar la herramienta delorean, la cual permitirá modificar los paquetes NTP que mande la victima de forma que se pueda modificar la fecha de esta máquina. Para ello, en la máquina atacante debemos descargar el repositorio Github de la herramienta mediante:
```
$ git clone https://github.com/PentesterES/Delorean.git
```

Una vez realizados los pasos anteriores, podemos proceder a realizar el ataque.


## Ejecución del ataque



## Autores
* José Ángel Martín Baos
* Óscar Pérez Galán


## AVISO LEGAL Y DESCARGO DE RESPONSABILIDAD:
Toda la información, enlaces y herramientas de este sitio web tiene estricto carácter formativo. Los autores NO aceptan ninguna responsabilidad por las posibles consecuencias, intencionadas o no, de las acciones realizadas mediante el uso de los materiales expuestos.

----------------------------------------------------
Seguridad en Redes - 2017 <br>
Escuela Superior de Informática <br>
Universidad de Castilla-La Mancha (Spain)
