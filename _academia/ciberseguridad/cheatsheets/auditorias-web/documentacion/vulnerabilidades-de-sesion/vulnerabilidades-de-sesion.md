---
title: Vulnerabilidades de sesión
description: Resumen rápido de comandos esenciales para realizar ataques de sesión.
layout: academia_lesson
parent: /academia/ciberseguridad/cheatsheets/auditorias-web/documentacion/vulnerabilidades-de-sesion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [sesion]
---

## Firma o algoritmo poco robusto 

Primero iniciamos sesión con credenciales válidas (`wiener:peter`) y activamos la opción “Recordarme / Stay logged in”. Esto provoca que la aplicación genere una cookie persistente que permite autenticarse sin volver a introducir la contraseña.

La cookie relevante es `stay-logged-in`, que controla este comportamiento:

~~~
Cookie: stay-logged-in=d2llbmVyOjUxZGMzMGRkYzQ3M2Q0M2E2MDExZTllYmJhNmNhNzcw;
~~~

Al decodificarla desde **Base64**, observamos que su contenido es legible:

~~~
wiener:51dc30ddc473d43a6011e9ebba6ca770
~~~

Esto indica que la cookie no está cifrada, solo codificada. El formato es `usuario:hash`. Por la longitud y los caracteres del hash podemos identificar que se trata de **MD5**. Al comprobar que el MD5 de la contraseña `peter` coincide, confirmamos cómo se construye la cookie.

La estructura final es:

~~~
base64(username+':'+md5HashOfPassword)
~~~

### Fuerza bruta de la cookie

Una vez conocida la estructura, interceptamos la petición que accede a la cuenta del usuario:

~~~
GET /my-account?id=wiener HTTP/2
...
GET /my-account?id=wiener HTTP/2
Cookie: stay-logged-in=...; session=...
~~~

La cookie `session` puede eliminarse, ya que la autenticación depende únicamente de `stay-logged-in`. A continuación, cambiamos el parámetro `id` por el usuario objetivo (`carlos`) y marcamos el valor de `stay-logged-in` para realizar fuerza bruta.

~~~
GET /my-account?id=carlos HTTP/2
Cookie: stay-logged-in=$PAYLOAD$
~~~

En Intruder configuramos el **payload processing** para que cada contraseña de la lista se transforme al formato esperado por la aplicación: primero se calcula el MD5, luego se añade el prefijo `carlos:` y finalmente se codifica en Base64.

- Hash: MD5
- Add Prefix: carlos
- Base64-encode

El intento correcto se identifica fácilmente, ya que la respuesta devuelve HTTP **200** en lugar de HTTP **302**, indicando acceso exitoso a la cuenta.

### Rainbow Tables

Si la fuerza bruta falla o queremos probar un método más rápido, podemos recurrir a Rainbow Tables.
Estas tablas son listas precomputadas de hashes y sus contraseñas correspondientes, que permiten descifrar hashes conocidos como MD5 sin calcularlos uno por uno.

Por ejemplo, buscando un hash MD5 en internet, podemos usar servicios como [md5decrypt.net](https://md5decrypt.net/en/)

Si tenemos el hash:

~~~
26323c16d5f4dabff3bb136f2460a943
~~~

El sitio nos devuelve la contraseña original:

~~~
onceuponatime
~~~