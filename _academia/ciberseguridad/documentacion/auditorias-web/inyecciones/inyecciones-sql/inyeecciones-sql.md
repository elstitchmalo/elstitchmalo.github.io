---
title: Inyecciones SQL
description: Qué son, tipos y cómo funcionan las inyecciones SQL.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones/inyecciones-sql/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL]
---

La inyección SQL (SQLi) es una vulnerabilidad que ocurre cuando una aplicación construye consultas SQL incorporando datos no confiables (entrada de usuario) sin tratarlos correctamente. En lugar de ser tratados como datos, esos valores se interpretan como parte de la propia sentencia SQL, permitiendo al atacante alterar la consulta que llega a la base de datos. El resultado puede ser desde la lectura no autorizada de datos hasta la modificación o borrado de información, bypass de autenticación o, en escenarios más graves, ejecución de comandos con privilegios de base de datos.

## Tipos de SQL Injection

### **1. Según el canal de comunicación**

  - [**Inyección SQL en banda**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/en-banda/introduccion)  
    El atacante obtiene los resultados a través del mismo canal que usa para enviar la inyección (por ejemplo, la respuesta HTTP de la web).  

    - [**Inyección SQL basada en errores**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/en-banda/basadas-en-errores)  
      Usa mensajes de error generados por la base de datos para extraer información (nombre de BD, versión, estructura).  

    - [**Inyección SQL basada en UNION**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/en-banda/basadas-en-union)  
      Usa la cláusula `UNION SELECT` para unir los resultados de una consulta maliciosa con la consulta original y así verlos directamente en la respuesta HTTP.  

  - [**Inyección SQL ciega**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/introduccion)  
    No devuelve resultados directamente. El atacante deduce información observando cambios en el comportamiento, el contenido o el tiempo de respuesta del servidor.  

    - [**Inyección SQL basada en condicionales**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/basadas-en-condicionales)  
      Deducción por verdadero/falso. Se analiza si la página cambia o no.  

     - [**Inyección SQL basada en errores condicionales**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/basadas-en-errores-condicionales)  
      Deducción por verdadero/falso provocando un error. Se analiza si se devuelve un error o no. 

    - [**Inyección SQL basada en tiempo**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/ciegas/basadas-en-tiempo)  
      Deducción por tiempo de respuesta. El atacante provoca retardos condicionales.  

  - [**Inyección SQL fuera de banda (OAST)**](../../../inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/fuera-de-banda/fuera-de-banda-oast)  
    El atacante no recibe información por el canal normal, sino a través de un canal alternativo externo, como DNS o HTTP callbacks.  

### **2. Según el contexto de ejecución**

  - [**Consultas apiladas**](../../../inyecciones/inyecciones-sql/segun-el-contexto-de-ejecucion/consultas-apiladas)  
    El atacante inserta varios comandos SQL en una misma petición separándolos con `;`. 

  - [**Inyección SQL de segundo orden**](../../../inyecciones/inyecciones-sql/segun-el-contexto-de-ejecucion/de-segundo-orden)  
    La inyección se almacena primero y se ejecuta más tarde, cuando otro proceso o función usa ese dato en una consulta SQL.  

  - [**Client-Side / API / JSON / GraphQL (contexto moderno)**](../../../inyecciones/inyecciones-sql/segun-el-contexto-de-ejecucion/client-side-api-json-graphql)  
    No es un tipo nuevo a nivel teórico, sino una variación contextual.  
    La inyección ocurre dentro de peticiones JSON, GraphQL o API REST, pero sigue siendo in-band o blind según la extracción de datos.  

## ¿Cómo detectar vulnerabilidades de inyección SQL?

1. Insertar `'` o `"` -> ¿aparecen errores?

    - Sí -> Probablemente **Inyección SQL basada en errores** (en banda). Investigar mensaje para info.
    - No -> Sigue.

2. Insertar `' UNION SELECT NULL...` (incrementando NULLs) -> ¿aparecen datos inyectados?

    - Sí -> **Inyección SQL basada en UNION** (en banda).
    - No -> Sigue.

3. Insertar `' AND 1=1...` y `' AND 1=2...` ¿cambia la respuesta?

    - Sí -> **Inyección SQL basada en condicionales** (ciega)
    - No -> Sigue.

4. Insertar `' AND SLEEP(5)...` (o su variante por motor) -> ¿hay un retardo claro y reproducible?

    - Sí -> **Inyección SQL basada en tiempo** (ciega).
    - No -> Sigue.

5. Insertar payloads OAST con Interactsh/Burp Collaborator -> ¿hay callback?

    - Sí -> **Inyección SQL fuera de banda (OAST)**
    - No -> Si el parámetro acepta escritura y hay flujos posteriores, considera que pueda haber una **Inyección SQL de segundo orden** o revisión del contexto (JSON, GraphQL, driver que sanitiza, etc.).

## Vectores de ataque

Una inyección SQL puede aparecer en cualquier punto donde la aplicación combine entrada de usuario con una consulta SQL sin un filtrado o parametrización adecuados.
A continuación se muestran los principales vectores, agrupados por tipo de entrada y contexto.

- **Parámetros clásicos en peticiones HTTP**:

  - **Parámetros GET**:   
    Variables en la URL, típicas en endpoints visibles o valores embebidos en la propia URL:
    ~~~
    /product.php?id=123' OR 1=1 --
    /api/v1/product/45' OR 1=1 #
    ~~~

  - **Parámetros POST** (form-data / x-www-form-urlencoded):  
    Datos enviados desde formularios web:
    ~~~ 
    POST /login
    username=admin&password=admin' OR 1=1 --
    ~~~

- **Formatos estructurados** (APIs modernas):

  - **JSON** (REST APIs):  
    Datos enviados como JSON en APIs modernas:
    ~~~ json
    {"user":"admin","filter":"' OR 1=1 --"}
    ~~~

  - **GraphQL**:  
    Campos, filtros y argumentos dentro de queries GraphQL:
    ~~~ graphql
    {
      users(filter: "' OR 1=1 --") {
        id
        name
      }
    }
    ~~~

  - **SOAP/XML** (nodos que se pasan a queries):  
    Datos estructurados en servicios web tradicionales:  
    ~~~ xml
    <user>
      <name>' OR 1=1 --</name>
    </user>
    ~~~

- **Datos en cabeceras HTTP**:

  - **Headers** (e.g., X-User-Id, Referer, User-Agent):  
    Algunas aplicaciones usan valores de cabecera para búsquedas o logging:  
    ~~~ makefile
    X-User-Id: 5' OR 1=1 #
    Referer: /dashboard
    User-Agent: test
    ~~~

- **Datos en Cookies**:

  - **Cookies**:  
    Cookies con valores que el servidor usa en consultas:
    ~~~ makefile
    Cookie: session_id=123' OR 1=1 --
    ~~~

## Características básicas del lenguaje SQL

Algunas características básicas del lenguaje SQL se implementan de la misma manera en las plataformas de bases de datos más populares, por lo que muchas formas de detectar y explotar las vulnerabilidades de inyección SQL funcionan de forma idéntica en diferentes tipos de bases de datos.

Sin embargo, también existen muchas diferencias entre las bases de datos comunes. Esto significa que algunas técnicas para detectar y explotar la inyección SQL funcionan de manera diferente en distintas plataformas. Por ejemplo:

- Sintaxis para la concatenación de cadenas.
- Comentarios.
- Consultas por lotes (o apiladas).
- API específicas de la plataforma.
- Mensajes de error.

> Esta [Cheat Sheet PortSwigger](https://portswigger.net/web-security/sql-injection/cheat-sheet) contiene ejemplos de sintaxis útil que puede utilizar para realizar diversas tareas que suelen surgir al realizar ataques de inyección SQL.

A continuación, algunos de los ejemplos más comunes:

En **Oracle**, cada consulta `SELECT` debe usar la palabra clave `FROM` y especificar una tabla válida. Existe una tabla integrada en Oracle llamada `DUAL` que se puede usar para este propósito. Por lo tanto, las consultas inyectadas en Oracle deberían tener el siguiente aspecto:  

~~~ 
SELECT NULL FROM DUAL
~~~

En **MySQL**, la secuencia de doble guion `--` debe ir seguida de un **espacio**. Como alternativa, se puede usar el carácter de almohadilla `#` para comentar. Por ejemplo:

~~~
' ORDER BY 1 #
~~~

A continuación se muestra una tabla con algunas palabras claves que difieren dependiendo de la base de datos:

| Base de datos    | Límites / paginado   | Longitud                              | Subcadena                                                     | Notas rápidas |
|------------------|----------------------|---------------------------------------|---------------------------------------------------------------|--------------------------------------------------------------------------------|
| Microsoft        | `TOP`                | `LEN(expr)`                           | `SUBSTRING(expr, start, length)`                              |                                                                                |
| MySQL            | `LIMIT`              | `LENGTH(expr)`, `CHAR_LENGTH(expr)`   | `SUBSTRING(expr, pos, len)`, `SUBSTR(expr,pos,len)`           | `LENGTH()` devuelve bytes; `CHAR_LENGTH()` cuenta caracteres (útil con UTF‑8). |
| PostgreSQL       | `LIMIT`, `OFFSET`    | `LENGTH(expr)`                        | `SUBSTRING(expr FROM pos FOR len)`, `SUBSTRING(expr,pos,len)` | `LENGTH(expr)` cuenta caracteres.                                              |
| Oracle           | `ROWNUM`             | `LENGTH(expr)`                        | `SUBSTR(expr, pos, len)`                                      |                                                                                |

## Información sobre base de datos

### Extraer información sobre la versión de la base de datos

Es posible identificar tanto el tipo como la versión de la base de datos inyectando consultas específicas del proveedor.  

| Base de datos    | Palabras claves   | Descripción    |
|------------------|-------------------|----------------|
| Microsoft, MySQL | `@@version`       |                |
| PostgreSQL       | `version()`       |                |
| Oracle           | `v$version`       |                |

Las siguientes son algunas consultas para determinar la versión de la base de datos para algunos tipos de bases de datos populares:

~~~ sql
# Microsoft, MySQL

SELECT @@version 
~~~
~~~ sql
# Oracle

SELECT * FROM v$version
~~~
~~~ sql
# PostgreSQL

SELECT version()
~~~

### Extraer información sobre el contenido de la base de datos

| Base de datos                | Palabras claves                                           | Descripción                                                               |
|------------------------------|-----------------------------------------------------------|---------------------------------------------------------------------------|
| Microsoft, MySQL, PostgreSQL | `information_schema.tables`, `information_schema.columns` | `.tables` para listar tablas y `.columns` para listar columnas            |
| Oracle                       | `all_tables`, `all_tab_columns`                           | `all_tables`  para listar tablas y `all_tab_columns` para listar columnas | 

#### Excepto Oracle

La mayoría de los tipos de bases de datos **(excepto Oracle)** tienen un conjunto de vistas llamado esquema de información. Este proporciona información sobre la base de datos.

Por ejemplo, se puede realizar una consulta a `information_schema.tables` para listar las tablas de la base de datos:

~~~ sql
# Microsoft, MySQL, PostgreSQL

SELECT * FROM information_schema.tables
~~~

También se puede realizar una consulta a `information_schema.columns` para listar las columnas de cada tabla individual.

~~~ sql
# Microsoft, MySQL, PostgreSQL

SELECT * FROM information_schema.columns WHERE table_name = 'Users'
~~~

#### Oracle

**En Oracle**, se pueden listar las tablas mediante una consulta a `all_tables`, de la siguiente manera:

~~~ sql
# Oracle

SELECT * FROM all_tables
~~~

Para listar las columnas, se puede realizar una consulta a `all_tab_columns`, de la siguiente manera:

~~~ sql
# Oracle

SELECT * FROM all_tab_columns WHERE table_name = 'USERS'
~~~

### Recuperar múltiples valores dentro de una sola columna

Se pueden recuperar múltiples valores juntos dentro de una única columna concatenando los valores. Ademas, se puede incluir un separador para distinguir los valores combinados, por ejemplo `'~'`.

| Base de datos      | Palabras claves   | Descripción    |
|--------------------|-------------------|----------------|
| Oracle, PostgreSQL | `||`              |                |
| Microsoft          | `+`               |                |
| MySQL              | `,`               |                |

Las siguientes son algunas consultas para concatenar valores para algunos tipos de bases de datos populares:

~~~ sql
# Oracle, PostgreSQL

SELECT username || '~' || password FROM users
~~~

~~~ sql
# Microsoft

SELECT username + '~' + password FROM users
~~~

~~~ sql
# MySQL

SELECT CONCAT(username, '~', password) FROM users
~~~

## ¿Cómo prevenir la inyección SQL?

La mayoría de los ataques de inyección SQL se pueden prevenir utilizando consultas parametrizadas en lugar de concatenar cadenas dentro de la consulta. Estas consultas parametrizadas también se conocen como "sentencias preparadas" (prepared statements).

El siguiente código es vulnerable a la inyección SQL porque la entrada del usuario se concatena directamente en la consulta:

~~~
String query = "SELECT * FROM products WHERE category = '"+ input + "'";
Statement statement = connection.createStatement();
ResultSet resultSet = statement.executeQuery(query);
~~~

Se puede reescribir este código de forma que se impida que la entrada del usuario interfiera con la estructura de la consulta:

~~~
PreparedStatement statement = connection.prepareStatement("SELECT * FROM products WHERE category = ?");
statement.setString(1, input);
ResultSet resultSet = statement.executeQuery();
~~~

Se puede usar consultas parametrizadas en cualquier situación donde aparezcan datos no confiables dentro de la consulta, incluyendo la cláusula `WHERE` y los valores en una instrucción `INSERT` o `UPDATE`. No se pueden usar para manejar datos no confiables en otras partes de la consulta, como nombres de tablas o columnas, o la cláusula `ORDER BY`. La funcionalidad de la aplicación que coloca datos no confiables en estas partes de la consulta debe adoptar un enfoque diferente, como:

- Lista blanca de valores de entrada permitidos.
- Utilizando una lógica diferente para lograr el comportamiento requerido.

Lista blanca de valores de entrada permitidos.
Utilizando una lógica diferente para lograr el comportamiento requerido.

Para que una consulta parametrizada sea eficaz para prevenir la inyección SQL, la cadena utilizada en la consulta siempre debe ser una constante codificada. Nunca debe contener datos variables de ningún origen. No caiga en la tentación de decidir caso por caso si un dato es de confianza, y siga utilizando la concatenación de cadenas dentro de la consulta para los casos que se consideren seguros. Es fácil cometer errores sobre el posible origen de los datos, o que cambios en otro código contaminen datos de confianza.

## CheatSheet

Colección de CheatSheets para pruebas y ataques de inyección SQL:

- [CheatSheet PortSwigger](https://portswigger.net/web-security/sql-injection/cheat-sheet)

- [Ofuscar ataques PortSwigger](https://portswigger.net/web-security/essential-skills/obfuscating-attacks-using-encodings)

- [Inyecciones SQL](../../../../../cheatsheets/auditorias-web/documentacion/inyecciones-sql)

## FuzzLists

Lista de payloads para detectar si la aplicación es vulnerable a ataques de inyección SQL:

- [Fuzzing básico](../../../../../fuzzlists/inyecciones-sql/fuzzing-basico)

## Herramientas

Colección de herramientas para pruebas y ataques de inyección SQL:

- [SQLmap](../../../../../herramientas/auditorias-web/herramientas-de-escaneo-automatico/sqlmap)  

- [Burp Scanner](../../../../../herramientas/auditorias-web/herramientas-de-escaneo-automatico/burp-scanner)  

- [Burp Collaborator](../../../../../herramientas/auditorias-web/interacciones-fuera-de-banda/burp-collaborator)  

- [Interactsh](../../../../../herramientas/auditorias-web/interacciones-fuera-de-banda/interactsh)  

- [Hackvertor](../../../../../herramientas/auditorias-web/codificacion-y-ofuscacion/hackvertor)  








