---
title: Client-Side / API / JSON / GraphQL
description: Explicación de las consultas Client-Side / API / JSON / GraphQL.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones/inyecciones-sql/segun-el-contexto-de-ejecucion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [consultas Client-Side-API-JSON-GraphQL]
---

Estos no son nuevos tipos teóricos de SQLi, sino contextos de entrada modernos donde puede darse la inyección: cuerpos JSON en APIs REST, argumentos en GraphQL, parámetros en requests AJAX o valores manipulados en el cliente antes de enviarlos al servidor. En estos contextos la inyección funciona igual ([inyección SQL en banda](../../segun-el-canal-de-comunicacion/en-banda/introduccion), [inyección SQL ciega](../../segun-el-canal-de-comunicacion/ciegas/introduccion) u [inyección SQL fuera de banda](../../segun-el-canal-de-comunicacion/fuera-de-banda/fuera-de-banda-oast)) pero cambia el vector y la sintaxis: los payloads deben insertarse en JSON, variables GraphQL, cabeceras o datos multipart. Es imprescindible auditar APIs, endpoints JSON, resolvers GraphQL y la lógica cliente/servidor, porque las aplicaciones modernas a menudo exponen superficies que no aparecen en páginas HTML tradicionales.

Estos distintos formatos pueden ofrecer diferentes maneras de [ofuscar ataques](https://portswigger.net/web-security/essential-skills/obfuscating-attacks-using-encodings) que, de otro modo, quedarían bloqueados por los WAF y otros mecanismos de defensa. Las implementaciones débiles suelen buscar palabras clave comunes de inyección SQL en la solicitud, por lo que es posible eludir estos filtros codificando o escapando los caracteres de las palabras clave prohibidas. Por ejemplo, la siguiente inyección SQL basada en XML utiliza una secuencia de escape XML para codificar el carácter `S` en `SELECT`:

~~~
<stockCheck>
    <productId>123</productId>
    <storeId>999 &#x53;ELECT * FROM information_schema.tables</storeId>
</stockCheck>
~~~

Esto se decodificará en el servidor antes de pasarse al intérprete de SQL.
