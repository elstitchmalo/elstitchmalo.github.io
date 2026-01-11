---
title: JWT
description: Resumen rápido de comandos esenciales para realizar ataques a JWT.
layout: academia_lesson
parent: /academia/ciberseguridad/cheatsheets/auditorias-web/documentacion/vulnerabilidades-de-autenticacion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [JWT]
---

## Aceptar firmas arbitrarias

Modificar el contenido del token. No se verifica la firma.

## Aceptar tokens sin firma

Modificar el contenido del token, cambiar el `alg` a `none` y mantener la estructura del JWT correctamente acabando con `.`.

## Fuerza bruta de claves secretas

Realizar fuerza bruta al JWT y una vez conseguida la clave, modificar el contenido del token y firmarlo con esa misma clave.

## Inyección de JWT autofirmados a través del parámetro jwk

- Con la extensión de Burp `JWT Editor` generamos una nueva clave RSA.
- Modificamos el contenido del token.
- Realizamos un ataque de JWK embedded

## Inyección de JWT autofirmados a través del parámetro jku

- Con la extensión de Burp `JWT Editor` generamos una nueva clave RSA.
- En el servidor de exploit, guardamos la clave JWK que se ha generado de la siguiente forma

~~~
{
    "keys": [
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "729cab22-c0e5-40fa-aefd-90a04575f309",
            "n": "geBwWPJaZymjyUm1QCz7E8nHW8JE5LeofT1zRCfabzW5exvFk5sC-3N5UKpxFmfgVPyPYKieNU8NXg9FQoJ5fo7oI3xB6wgkHiWxS92ywjsfEEuYr5KY_kPvUI7jBIWs_2VCCIqPCp7VrosQgILBsH8OWwzXUhimInqaajG6wPGc6Li-WqT7QfMYEq9zCMFoZqfgI4oO8vI6K3n-sY_78f0uKpOCAQPSGa4ZV_fyqjjrNjLb6WyOLB0yfefXUVymb1lDz7yAfDVkVAL0-zQheywpD7jQPpbaI6QcTyUwXsJ_MrViuBQDhA6yHYjSzSOq7bVhe0ub0oItfRQon-dkiw"
        }
    ]
}

~~~

- Modificamos el contenido del token.
    - Cambiamos el `kid` por el mismo que hemos guardado en el servidor de exploit
    - Cambiamos el usuario
- Firmamos el token **sin modificar la cabecera** con la clave RSA que hemos generdo

## Inyección de JWT autofirmados a través del parámetro kid

- Modificar el parametro `kid` a `../../../../../../../../dev/null`
- Seleccionar con la extensión de Burp `JWT Editor` la opción de "firmar con clave vacia"

## Confusión del algoritmo JWT

- Obtener la clave pública de `/jwks.json`
- Convertirla en formato PEM
- Encodear la clave pública formateada en Base64
- Crear una nueva clave simétrica y cambiar el valor generado `k` por el base64
- Modificar el token y firmalo con el algoritmo `HS256` y la clave genérica creada

### Confusión del algoritmo JWT derivando claves públicas a partir de tokens existentes

- Obtener dos JWT diferentes iniciando sesión dos veces
- Ejecutar comando 

    ~~~
    docker run --rm -it portswigger/sig2n <token1> <token2>
    ~~~

- Copiar el resultado  que nos devuelve en formato `Base64 encoded x509 key`
- Crear una nueva clave simétrica y cambiar el valor generado `k` por el base64
- Modificar el token y firmalo con el algoritmo `HS256` y la clave genérica creada