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

Una vez realizado los pasos anteriores tendremos el entorno de trabajo montado y configurado. Este entorno estará compuesto por una red interna, en la cual están conectadas las tres máquinas (router, victima y atacante) en las direcciones ip *192.168.5.1*, *192.168.5.2* y *192.168.5.3* respectivamente. A partir de este momento, solo vamos a trabajar usando la máquina victima (desde la interfaz gráfica) y la máquina atacante (desde la consola mediante conexión ssh).


## Descarga e instalación de las herramientas necesarias
Para poder realizar el ataque, es necesario instalar algunas herramientas en la máquina atacante. El uso de estas herramientas serán explicadas posteriormente. La primera de ellas será *arpspoof*, que nos permitirá realizar el ataque "man in the middle" propiamente dicho, mediante la falsifiación de paquetes ARP. La siguiente herramienta será *iptables*, que es un firewall de filtrado de paquetes del kernel de Linux (por lo que no será necesario instalarla). También se necesiará la herramienta *SSLSTrip*, la cual va a permitir convertir todo el HTTPS de una web en HTTP (sin cifrar) y por tanto engañar a la victima, para obtener sus datos. Estos programás serán instalados usando lo siguientes comandos en la máquina atacante:
```
$ sudo apt-get update
$ sudo apt-get install dsniff sslstrip 
```

Por último será necesario descargar la herramienta *Delorean*, la cual permitirá modificar los paquetes NTP que mande la victima de forma que se pueda modificar la fecha de esta máquina. Para ello, en la máquina atacante debemos descargar el repositorio Github de la herramienta mediante:
```
$ git clone https://github.com/PentesterES/Delorean.git
```

Una vez realizados los pasos anteriores, podemos proceder a realizar el ataque.


## Ejecución del ataque
 ### Finalidad y explicación del ataque
La finalidad de este ataque es demostrar como poder saltarse la seguridad establecida por HSTS la cual fuerza que las comunicaciones HTTP vayan sobre un canal TLS/SSL para hacer las mismas seguras. Para ello vamos a trabajar con una idea muy sencilla y elegante que fue ideada José Selvi, y que consiste en la utilización del protocolo NTP como herramienta de bypass para HSTS, esto lo conseguimos gracias a un esquema de MITM mediante el cual realizaremos modificaciones a los paquetes NTP destinados en un principio a la maquina victima para hacer que dicho sistema victima viaje al futuro consiguiendo así caducar el TTL(Time to live) de la configuración HSTS, y por tanto eliminando la capa de seguridad que protege las conexiones HTTP. Una vez eliminada la seguridad de la conexión haremos uso de la herramienta desarrollada por Moxie Marlinspike llamada SSLStrip que nos permitirá extraer información acerca de estas conexiones no seguras, obteniendo así todo tipo de información web sobre la victima.

  ### Protocolos involucrados
  
NTP -> que es utilizado para sincronizar la fecha y hora de nuestro sistema con unos pocos milisegundos de diferencia con respecto al UTC (Universal Time Coordinated). puede estar implementado en varios modelos como el tipo cliente-servidor o un peer-to-peer. La versión utilizada de NTP en la ntpv4 ntpv3 según el sistema operativo usado, que utiliza datagramas UDP y opera en el puerto 123. NTP usa un sistema de jerarquías para sus fuentes de tiempo, cada capa es conocida como stratum, donde el stratum 0 corresponde al padre de todas las capas, y está directamente ligado a los relojes atómicos.

ARP -> 

HTTP ->  Es un protocolo sin estado, utilizado para realizar las transferencias en la World Wide Web.

HTTPS -> Basado en HTTP, y destinado a la transferencia segura de HTTP mediante el uso de un cifrado SSL / TLS que crea un canal de cifrado.

SSL/TLS -> Ambos son protocolos criptográficos, que proporcionan comunicaciones seguras por una red. usan cifrados X.509 (asimétricos) para autenticar la contraparte con quien se estén comunicando, y para intercambiar una llave simétrica.

### Herramientas utilizadas

SSLSTRIP -> Esta herramienta es capaz de "descifrar" el tráfico HTTPS y esnifar todo el tráfico (usuarios y claves) que viajen a través de la red en HTTPS. Realmente la herramienta no descifra el cifrado impuesto por SSL, si no que su función real es la de engañar al servidor y forzar que todo el tráfico HTTPS  pase a HTTP el cual no esta cifrado.


DELOREAN -> Es un servidor NTP escrito en python,con el que básicamente nosotros vamos a poder realizar una captura de todo el trafico NTP y realizar modificaciones en dichos paquetes, pudiendo de esta manera establecer una nueva fecha de sistema y así hacer viajar a la victima hacia el futuro.

 #### Modos de funcionamiento:
   Automatico -> si no especificamos ningun parametro de entrada Delorean trabajara por defecto utilizando una fecha 1000 dias posterior a la actual, manteniendo el mismo dia y mes para evitar levantar sospechas.
   
   Step Mode (-s) -> En este modo nosotros podemos elegir cuantos segundo,horas o dias queremos avanzar.
   
   Date mode (-d) -> Con este modo tu puedes elegir la fecha exacta a la que quieres hacer viajar a la victima.
   
   Random mode (-r) -> El Delorean comenzara a enviar fechas aleatorias al sistema victima, puede ser util para testear overflows.
   
   Skimming Attack (-k & -t) -> Este modo funciona de 2 formas. Por un lado con -k avanza al futuro en varios pasos en lugar de en uno solo. La opcion -t lo que nos permite es usar los saltos en el tiempo establecidos con -k pero esta vez retorcediendo hacia el pasado, con lo que por ejemplo podriamos reutilizar viejos certifcados ya caducados en la maquina victima.
   
#### Vulnerabilidades de los sistemas operativos:
 Ubuntu Linux -> No tiene un demonio NTP corriendo por el mismo, pero utiliza una configuracion por defecto via 'ntpdate', este comando hace una peticion cada vez que una interfaz de red se levanta. Utiliza NTPv4 sin autenticación, por tanto vulnerables a MITM.
 
 Fedora Linux -> al contrario que en Ubuntu Fedora si utiliza un demonio NTP llamado 'chronyd' cada hace sincronizaciones cada minuto. Utiliza NTPv3 sin autenticacion, de modo que es vulnerable a ataques MITM.
 
 Mac OS X Lion -> Cuenta con un demonio NTP llamado 'ntpd' que sincronizaria cada 9 minutos, utiliza NTPv4 sin autenticacion, por tanto tambien es vulnerable.
 
 Microsoft Windows -> Este es el sistema con la implementación mas segura de NTP, tampoco utiliza autenticacion, pero implementa algunas características adicionales que aportan un extra de seguridad y de dificultad para realizar el ataque. Su periodo de sincronizacionn esta entorno a 1 semana. La segunda característica de seguridad son los paramtros 'MaxPosPhaseCorrection' y 'MinPosPhaseCorrection' situado en el registro de Windows, especificando el máximo y el mínimo tiempo en segundos que el reloj puede ser reajustado con una sincronizacionn, estos valores están entorno a unas 15 horas. Esto deja una estrecha posibilidad para realizar un ataque ya que salvo que el usuario tenga modificado el valor de 'MaxPosPhaseCorrection' no podremos llevar a cabo este ataque. Otro dato interesante es que si forzamos a que el usuario realice una petición de forma manual no se aplicaran ninguna de estas restricciones y sera vulnerable.

### Fortalezas y debilidades de HSTS

Esta política de seguridad fue ideada para evitar que se pudieran llevar a cabo los ataques de SSLStrip y que alguien pudiera robarnos información con ello. Con este método se asegura que nunca se va a navegar con HTTP ya que el servidor web declara que los navegadores utilizados (agentes de usuario), solo puedan navegar sobre este protocolo HTTPS.

El problema que tiene esta medida de seguridad, es que tiene un tiempo de vida establecido y gracias a la herramienta Delorean podemos hacer que esta seguridad desaparezca, siendo susceptible entonces a un ataque SSLStrip	

### Vulnerabilidad de NTP
NTPv4 soporta autenticación basada en cifrado asimétrico en su capa Message Digest que impide que el timestamp sea modificado. El servidor firma el mensaje NTP usando su clave privada, por tanto el cliente podra verificar la integridad del mensaje, y por tanto no puede realizarse un ataque de MITM. Pero si tenemos en cuenta que practicamente ningun sistema operativo implementa este sistema de autenticación, por lo que realmente si serian vulnerables a un MITM.


### Contextualización del ataque

En nuestro entorno de pruebas contaremos con una maquina victima, un atacante y un router. sobre este esquema la idea sera capturar todos los paquetes provenientes de la victima a través de HTTP y NTP, para primero mediante el uso del Delorean consigamos llevar la maquina victima al futuro donde no tenga validez su TTL , con lo que quedara expuesta a un ataque de SSLStrip.

#### En que consiste el ataque MITM

El objetivo de dicho ataque es conseguir situarse en medio de la maquina victima y la maquina router, para lograr esto debemos hacer creer al router que nuestra maquina atacante es la victima, y conseguir también que la victima piense que nosotros somos el router.


### Iniciando el ataque
Lo primero a realizar sera la puesta en marcha de nuestro entorno, para ello ejecutar el siguiente comando donde tengáis descargado el Vagrantfile.
```
$ vagrant up
```

Una vez finalizada la ejecución del comando ya tendremos el entorno preparado para empezar a probar el ataque. veremos como nos ha levantado una maquina virtual con GUI (la victima) y 2 sin ella (router y atacante).

#### Comenzando ejecución desde maquina atacante

Accedemos desde la terminal que utilizamos para levantar nuestro entorno y accedemos a la maquina atacante mediante SSH:
```
$ vagrant ssh atacante
```

#### Realización del MITM

Si recordamos la primera parte del ataque, consistía en la puesta de nuestra maquina atacante en medio del router y la victima, para ello debemos modificar las caches ARP de las maquinas victima y router. Esto lo conseguimos a través de un ataque ARP spoof con el cual bombardeamos de mensajes ARP diciéndole a cada uno que somos el otro.

Le decimos al router que nosotros somos la maquina Victima:
```
$ sudo arpspoof -i eth0 -t 192.168.5.3 192.168.5.1
```
Le decimos a la Victima que nosotros somos el Router:

```
$ sudo arpspoof -i eth0 -t 192.168.5.1 192.168.5.3
```

Con esto si observamos en la cache de la maquina victima veríamos como la dirección MAC del router ha sido suplantada por la de nuestra maquina atacante al igual que en el caso del router. 

#### Interceptar paquetes NTP con Delorean

Ya hemos llevado a cabo el MITM y por tanto estamos en posición de empezar a capturar y modificar los paquetes que necesitamos para este ataque, que en este caso son paquetes NTP.


Para poder capturar los paquetes NTP necesitamos configurar una regla con iptables mediante la cual le diremos que no pueda hacer FORWARD de paquetes NTP, quedando todos los paquetes en nuestra maquina atacante que sera la encargada de modificar y reenviar estos paquetes a la victima.

```
$ sudo iptables -t nat PREROUTING -i eth0 -p udp --dport 123 -j REDIRECT --to-port 123  
```

Comprobaremos que la regla se guardo satisfactoriamente con iptables-save y ahora llega el momento de lanzar el Delorean, el cual podemos ejecutar en otra terminal. A partir de ahora solo es cuestión de tiempo hasta que la maquina victima realice una petición NTP y podamos modificarla, para empezar a enviar al futuro a nuestra victima.

```
$ ./Delorean.py
```

Ya podemos apreciar como la herramienta Delorean ha comenzado a reenviar los paquetes NTP con fecha cambiada (por defecto 10000 días).




#### Poner en funcionamiento SSLStrip

  ##### Redirecciones para SSLStrip
Para poder perpetrar este ataque de SSLStrip tenemos que hacer una ultima configuración en el firewall de la maquina atacante, que consiste en redireccionar todo el trafico que vaya por el puerto 80 y este enviarlo al puerto 8080 que es donde hemos configurado que escuche nuestro SSLStrip. Para esto estableceremos un nueva regla como la que vemos aquí:

``` 
$ sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
```
##### Capturando datos con SSLStrip
Como decíamos antes, todo lo realizado hasta ahora es lo necesario para poder saltarnos la seguridad añadida por SSL/TLS que nos impedía realizar un ataque SSLStrip, pero ahora gracias al Delorean hemos caducado su sesión TTL y por tanto podemos forzar de nuevo al navegador de la victima a navegar a través de HTTP y ser susceptible a SSLStrip, con lo que ahora ya podremos obtener mediante el sniffer los usuarios y contraseñas de todos los sitios web donde acceda la victima. 

```
$ ./sslstrip.py -l 8080 -w file.txt
```


## Autores
* José Ángel Martín Baos
* Óscar Pérez Galán


## AVISO LEGAL Y DESCARGO DE RESPONSABILIDAD:
Toda la información, enlaces y herramientas de este sitio web tiene estricto carácter formativo. Los autores NO aceptan ninguna responsabilidad por las posibles consecuencias, intencionadas o no, de las acciones realizadas mediante el uso de los materiales expuestos.

----------------------------------------------------
Seguridad en Redes - 2017 <br>
Escuela Superior de Informática <br>
Universidad de Castilla-La Mancha (Spain)
