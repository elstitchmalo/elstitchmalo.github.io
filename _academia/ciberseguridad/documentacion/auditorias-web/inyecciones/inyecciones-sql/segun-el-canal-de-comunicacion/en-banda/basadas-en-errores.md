---
title: Inyecciones SQL basadas en errores
description: Explicación de las inyecciones SQL basadas en errores.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones/inyecciones-sql/segun-el-canal-de-comunicacion/en-banda/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL basadas en errores]
---

Las inyecciones SQL basadas en errores explotan mensajes de error que la base de datos o la capa de acceso a datos devuelven en la respuesta. Si una entrada provoca una excepción o un fallo de conversión y ese detalle se refleja en la página (stack trace, mensaje del driver, código de error), el atacante puede leer información útil (versión, nombres de tablas/columnas, estructuras) y usarla para refinar ataques posteriores.

Es habitual forzar conversiones de datos invalidos usando `CAST` para producir errores que revelen datos o la estructura interna.

### Diferencias entre bases de datos

| Base de datos  | Palabras claves                                | Descripción    |
|----------------|------------------------------------------------|----------------|
| MySQL          | `CAST(... AS SIGNED)`, `CONVERT(..., SIGNED)`  |                |
| PostgreSQL     | `CAST(... AS INTEGER)`, `::integer`            |                |
| Microsoft      | `CAST(... AS INT)`, `CONVERT(INT, ...)`        |                |
| Oracle         | `CAST(... AS NUMBER)`, `TO_NUMBER()`           |                |

### Ejemplos de ataque

Imaginemos que existe una tabla `users` con las columnas `username` y `password`. Podemos obtener los usuarios y sus contraseñas provocando un error al intentar convertir con `CAST` esos valores a un tipo numérico inválido:

~~~
# Microsoft

' AND 1=CAST((SELECT TOP 1 username FROM users) AS INT) --
~~~
~~~
# Microsoft

' AND 1=CAST((SELECT TOP 1 password FROM users) AS INT) --
~~~
