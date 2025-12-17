---
title: Inyecciones SQL basadas en errores condicionales
description: Explicación de las inyecciones SQL basadas en errores condicionales.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL basadas en errores condicionales]
---

A menudo es posible lograr que la aplicación devuelva una respuesta diferente según si se produce un error de SQL. Se puede modificar la consulta para que genere un error de base de datos solo si la condición es verdadera. Con frecuencia, un error no controlado por la base de datos provoca alguna diferencia en la respuesta de la aplicación, como un mensaje de error. Esto permite deducir si la condición inyectada es verdadera.

### Señales a observar

- Errores.

### Ejemplos de ataque

Supongamos que se envían dos solicitudes que contienen los siguientes valores:

~~~
# PostgreSQL, MySQL, Microsoft

' AND (SELECT CASE WHEN (1=2) THEN 1/0 ELSE 'a' END)='a

' AND (SELECT CASE WHEN (1=1) THEN 1/0 ELSE 'a' END)='a
~~~

Estas entradas utilizan la palabra clave `CASE` para comprobar una condición y devolver una expresión diferente dependiendo de si la expresión es verdadera o no:

- Con la primera entrada, la expresión `CASE` se evalúa como `'a'`, lo cual no causa ningún error.

- Con la segunda entrada, se evalúa como `1/0`, lo que provoca un error de división por cero.

Si el error provoca una diferencia en la respuesta HTTP de la aplicación, se puede utilizar esto para determinar si la condición inyectada es verdadera.

Ahora, supongamos que queremos obtener la contraseña del usuario `administrator`, primero comprobamos que existe una tabla llamada `users` o similar en la base de datos (Oracle) y que tiene al menos una fila.

~~~ 
# Oracle

'||(SELECT '' FROM users WHERE ROWNUM = 1)||'
~~~

Como esta consulta no devuelve error, se puede inferir que esta tabla existe.

A continuación verificamos que existe el usuario `administrator` en la tabla `users`.

~~~
# Oracle

' ||(SELECT CASE WHEN (1=1) THEN TO_CHAR(1/0) ELSE '' END FROM users WHERE username='administrator')||'
~~~

Ya que la condición es verdadera (se recibe el error), se confirma que existe un usuario llamado `administrator`.

El siguiente paso es determinar cuántos caracteres tiene la contraseña del usuario `administrator`. Para ello, enviamos el siguiente payload:

~~~
# Oracle

' ||(SELECT CASE WHEN LENGTH(password)=1 THEN to_char(1/0) ELSE '' END FROM users WHERE username='administrator')||'
~~~

Esta condición debe ser verdadera (se recibe el error), lo que confirma que la contraseña tiene más de 1 carácter.

Ahora que ya sabemos que hay una tabla llamada `users` con las columnas `username` y `password`, y que existe un usuario llamado `administrator` del cual conocemos el numero de caracteres que tiene su contraseña. Podemos determinar la contraseña de este usuario enviándole una serie de entradas para probarla carácter por carácter.

~~~
# Oracle

' ||(SELECT CASE WHEN SUBSTR(password,1,1)='a' THEN TO_CHAR(1/0) ELSE '' END FROM users WHERE username='administrator')||'
~~~
~~~
# PostgreSQL, MySQL, Microsoft

' AND (SELECT CASE WHEN (Username = 'Administrator' AND SUBSTRING(Password, 1, 1) = 'm') THEN 1/0 ELSE 'a' END FROM Users)='a
~~~