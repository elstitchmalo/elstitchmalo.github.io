---
title: Inyecciones SQL basadas en tiempo
description: Explicación de las inyecciones SQL basadas en tiempo.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL basadas en tiempo]
---

Cuando no hay diferencias visuales fiables, las inyecciones SQL basadas en tiempo introducen retardos deliberados en la ejecución de la consulta para indicar si la condicion enviada es verdadera o falsa. 

Dado que las consultas SQL se procesan normalmente de forma síncrona por la aplicación, el retraso en la ejecución se traduce en un retraso en la respuesta HTTP. Midiendo esa latencia (comparándola con un baseline), podemos inferir el valor de la condición y, por tanto, extraer información.

El atacante mide el tiempo de respuesta del servidor (por ejemplo, usando `SLEEP` o `WAITFOR DELAY`) esperando un retraso significativo que indica que la condición evaluada por la consulta es verdadera, y la ausencia de retraso indica que es falsa. 

### Señales a observar

- Retrasos de tiempo.

### Diferencias entre bases de datos

| Base de datos  | Palabras claves                                                                    | Descripción                                                       |
|----------------|------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| MySQL          | `SLEEP()`                                                                          | Puede usarse inline con `IF(...)` o en una subconsulta.           |
| PostgreSQL     | `pg_sleep()`                                                                       | Se puede usar en `SELECT` o en `CASE WHEN ... THEN pg_sleep(...)` |
| Microsoft      | `WAITFOR DELAY 'hh:mm:ss'`                                                         | Normalmente requiere stacked queries (o en procedimientos)        |
| Oracle         | `DBMS_LOCK.SLEEP()`, `DBMS_SESSION.SLEEP()`, `dbms_pipe.receive_message(('a'),10)` | Puede requerir privilegios.                                       |

### Ejemplos de ataque

En Microsoft SQL Server, se puede usar lo siguiente para comprobar una condición y activar una demora según si la expresión es verdadera:

~~~ 
# Microsoft

'; IF (1=2) WAITFOR DELAY '0:0:10'--

'; IF (1=1) WAITFOR DELAY '0:0:10'--
~~~

- La primera de estas entradas no provoca un retardo, porque la condición `1=2` es falsa.
- La segunda entrada provoca una demora de 10 segundos, porque la condición `1=1` es verdadera.

Utilizando esta técnica, podemos recuperar datos probando un carácter a la vez:

~~~ 
# Microsoft

'; IF (SELECT COUNT(Username) FROM Users WHERE Username = 'Administrator' AND SUBSTRING(Password, 1, 1) > 'm') = 1 WAITFOR DELAY '0:0:10'--
~~~
