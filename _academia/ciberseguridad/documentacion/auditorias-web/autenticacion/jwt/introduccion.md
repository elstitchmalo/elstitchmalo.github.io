---
title: Introducción
description: Qué son, tipos y cómo funcionan las vulnerabilidades en JWT.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/jwt/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [JWT]
---

# ¿Qué son los JWT?

Un JWT (JSON Web Token) es un tipo de token, es decir, una “credencial digital” que un servidor entrega a un usuario para demostrar quién es y qué puede hacer dentro de una aplicación web.
Se utiliza principalmente en autenticación (comprobar quién es el usuario), gestión de sesiones (mantener al usuario conectado) y control de acceso (decidir a qué recursos puede acceder).

La característica más importante de un JWT es que toda la información necesaria viaja dentro del propio token, y se guarda en el navegador del usuario, no en el servidor. Por eso es muy usado en aplicaciones modernas con muchos servidores, donde compartir sesiones tradicionales sería complicado.

## Formato JWT

Un JWT está compuesto por tres partes, separadas por puntos (`.`):

~~~ 
eyJraWQiOiI5MTM2ZGRiMy1jYjBhLTRhMTktYTA3ZS1lYWRmNWE0NGM4YjUiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJwb3J0c3dpZ2dlciIsImV4cCI6MTY0ODAzNzE2NCwibmFtZSI6IkNhcmxvcyBNb250b3lhIiwic3ViIjoiY2FybG9zIiwicm9sZSI6ImJsb2dfYXV0aG9yIiwiZW1haWwiOiJjYXJsb3NAY2FybG9zLW1vbnRveWEubmV0IiwiaWF0IjoxNTE2MjM5MDIyfQ.SYZBPIBg2CRjXAJ8vCER0LA_ENjII1JakvNQoP-Hw6GG1zfl4JyngsZReIfqRvIAEi5L4HV0q7_9qGhQZvy9ZdxEJbwTxRs_6Lb-fZTDpW6lKYNdMyjw45_alSCZ1fypsMWz_2mTpQzil0lOtps5Ei_z7mM7M8gCwe_AGpI53JxduQOaB5HkT5gVrv9cKu9CsW5MS6ZbqYXpGyOG5ehoxqm8DL5tFYaW3lB50ELxi0KsuTKEbD0t5BCl0aCR2MBJWAbN-xeLwEenaqBiwPVvKixYleeDQiBEIylFdNNIMviKRgXiYuAvMziVPbwSgkZVHeEdF5MQP1Oe2Spac-6IfA
~~~

1. **Encabezado (Header)**  
    Contiene información técnica sobre el token, como:

    - El tipo de token.
    - El algoritmo criptográfico usado para firmarlo (por ejemplo, RSA o HMAC).

2. **Carga útil (Payload)**  
    Contiene los datos del usuario, llamados claims o reclamos.  
    Estos datos pueden incluir:

    - Identidad del usuario.
    - Rol o permisos.
    - Fecha de expiración del token.

3. **Firma (Signature)**  
    Es el elemento de seguridad clave.
    Se genera usando:

    - El encabezado.
    - La carga útil.
    - Una clave secreta que solo conoce el servidor.

El encabezado y la carga útil no están cifrados, solo están codificados en Base64URL. Esto significa que cualquiera que tenga el token puede leer su contenido e incluso modificarlo.  

~~~
{
    "iss": "portswigger",
    "exp": 1648037164,
    "name": "Carlos Montoya",
    "sub": "carlos",
    "role": "blog_author",
    "email": "carlos@carlos-montoya.net",
    "iat": 1516239022
}
~~~

Por esta razón, la seguridad del JWT depende totalmente de la firma.

## Firma JWT

Cuando el servidor recibe un JWT:

- Recalcula la firma usando su clave secreta.
- Comprueba que coincida con la firma del token.
- Si no coincide, el token se considera manipulado y se rechaza.

Modificar incluso un solo carácter del token hace que la firma deje de ser válida.

## JWT frente a JWS frente a JWE

Aunque el término JWT (JSON Web Token) se usa muy a menudo en aplicaciones web, por sí solo no define un mecanismo completo de seguridad.
La especificación JWT únicamente describe cómo estructurar datos en formato JSON para enviarlos entre dos sistemas, pero no indica cómo proteger esos datos.

Para que un JWT sea realmente útil y seguro en una aplicación web, necesita apoyarse en otras dos especificaciones que añaden mecanismos de firma o cifrado.

La especificación JWT define solo:

- Un formato para representar información (llamada reclamos, es decir, datos sobre un usuario u otro sistema).

- Una estructura basada en JSON, pensada para ser enviada entre cliente y servidor.

Sin embargo, JWT no define cómo evitar que los datos sean modificados o espiados.
Por eso, en la práctica, los JWT siempre se usan junto con:

- JWS (JSON Web Signature)
Añade una firma criptográfica al token.
Esta firma permite verificar que el contenido no ha sido modificado desde que el servidor lo creó.

- JWE (JSON Web Encryption)
Añade cifrado al contenido del token.
Esto impide que terceros puedan leer los datos, incluso si obtienen el token.

En el uso real:

- Cuando se dice “JWT”, casi siempre se está hablando de un JWT firmado (JWS).

- Los JWE funcionan de forma similar, pero con el contenido cifrado en lugar de solo codificado.