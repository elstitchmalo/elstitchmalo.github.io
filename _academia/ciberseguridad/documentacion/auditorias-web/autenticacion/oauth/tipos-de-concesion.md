---
title: Tipos de concesión
description: Explicación de los diferentes tipos de concesión en OAuth.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/oauth/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [OAuth]
---

En OAuth, un tipo de concesión (o grant type) define cómo una aplicación obtiene permiso para acceder a los datos de un usuario.  
En otras palabras, describe el flujo paso a paso desde que el usuario da su consentimiento hasta que la aplicación recibe un token de acceso, que es una credencial que permite llamar a una API y obtener o modificar datos del usuario.

Estos flujos también se conocen como flujos de OAuth, y cada tipo tiene características de seguridad y complejidad distintas. Antes de usar un flujo, el servidor OAuth debe estar configurado para permitirlo, y la aplicación debe indicar qué flujo desea usar al enviar la solicitud de autorización inicial.

## Ámbitos (Scopes) en OAuth

Los ámbitos (o scopes) son permisos que la aplicación solicita sobre los datos del usuario. Por ejemplo, leer contactos, acceder al correo o ver información básica del perfil.

### Ámbitos personalizados

Cada proveedor de OAuth define sus propios ámbitos, que pueden tener distintos formatos:

- `scope=contacts`

- `scope=contacts.read`

- `scope=contact-list-r`

- `scope=https://oauth-authorization-server.com/auth/scopes/user/contacts.readonly`

### Ámbitos estandarizados (OpenID Connect)

Para autenticación (inicio de sesión), se usan ámbitos estándar de OpenID Connect, como:

- `openid profile` → acceso a información básica del usuario (nombre, correo electrónico, ID).

## Tipo de concesión recomendado: Código de autorización

El flujo de código de autorización es el más seguro porque los datos sensibles nunca viajan por el navegador. Todo el intercambio de tokens ocurre directamente entre servidores.

Resumen del flujo

1. La aplicación redirige al usuario al servidor OAuth.

2. El usuario inicia sesión y da su consentimiento.

3. La aplicación recibe un código de autorización.

4. La aplicación intercambia el código por un token de acceso a través de un canal seguro servidor a servidor.

5. Con el token, la aplicación accede a la API para obtener los datos solicitados.

6. Se reealizan las llamasdas a la API.

7. Si el token es valido, eel servidor devolvera los datos solicitados.

### Flujo paso a paso

#### 1. Solicitud de autorización

La aplicación envía una solicitud HTTP al servidor OAuth:

~~~
GET /authorization?client_id=12345&redirect_uri=https://client-app.com/callback&response_type=code&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: oauth-authorization-server.com
~~~

**Parámetros clave:**

- `client_id`: identificador público de la aplicación.

- `redirect_uri`: dirección de retorno tras la autorización. Es crítico validar correctamente este URI para evitar ataques.

- `response_type=code`: indica que se inicia el flujo de código de autorización.

- `scope`: define los permisos solicitados.

- `state`: valor aleatorio que protege contra ataques CSRF.

#### 2. Inicio de sesión y consentimiento

El usuario inicia sesión en el servidor OAuth y decide si acepta los permisos solicitados. Si ya ha aprobado permisos previamente, este paso puede ser automático.

#### 3. Entrega del código de autorización

Si el usuario acepta, el navegador se redirige a la `redirect_uri` con un código de autorización:

~~~
GET /callback?code=abc123&state=valor_aleatorio
~~~

Este código por sí solo no permite acceder a los datos.

#### 4. Solicitud del token de acceso

La aplicación intercambia el código por un token mediante una petición servidor a servidor:

~~~
POST /token HTTP/1.1
Host: oauth-authorization-server.com
…
client_id=12345&client_secret=SECRET&redirect_uri=https://client-app.com/callback&grant_type=authorization_code&code=a1b2c3d4e5f6g7h8
~~~

**Parámetros adicionales:**

- `client_secret`: clave privada de la aplicación, nunca expuesta al navegador.

- `grant_type`: asegura que el servidor OAuth sepa qué flujo se está usando.

#### 5. Emisión del token de acceso

El servidor OAuth responde con un token de acceso:

~~~
{
    "access_token": "z0y9x8w7v6u5",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "openid profile",
    …
}
~~~

#### 6. Llamada API

La aplicación usa el token para solicitar datos al servidor de recursos:

~~~
GET /userinfo HTTP/1.1
Host: oauth-resource-server.com
Authorization: Bearer z0y9x8w7v6u5
~~~

#### 7. Entrega de los datos

Si el token es válido, el servidor devuelve la información del usuario:

~~~
{
    "username":"carlos",
    "email":"carlos@carlos-montoya.net",
    …
}
~~~

Estos datos se usan, por ejemplo, para autenticar al usuario en la aplicación.

## Tipo de concesión implícita

El tipo de concesión implícita es un flujo más sencillo que el de código de autorización.  
En lugar de recibir primero un código de autorización y luego intercambiarlo por un token de acceso, la aplicación obtiene el token de acceso directamente justo después de que el usuario da su consentimiento.

### ¿Por qué no se usa siempre?

Aunque es más simple, este flujo es menos seguro que el de código de autorización.

En el flujo implícito:

- Toda la comunicación se realiza a través del navegador del usuario, mediante redirecciones.

- No existe un canal seguro servidor a servidor para intercambiar tokens.

- Esto significa que el token de acceso y los datos del usuario están más expuestos a posibles ataques.

Por estas razones, este flujo se utiliza principalmente en:

- Aplicaciones de página única (SPA), donde todo el código se ejecuta en el navegador.

- Aplicaciones de escritorio nativas que no pueden almacenar de forma segura un client_secret en un servidor.

En estos casos, no se aprovecha tanto la seguridad del flujo de código de autorización.

### Flujo del tipo de concesión implícita

#### 1. Solicitud de autorización

La aplicación inicia el flujo enviando una solicitud al servidor OAuth, de forma similar al flujo de código de autorización.  

La diferencia principal es que el parámetro `response_type` se establece en `token`:

~~~
GET /authorization?client_id=12345&redirect_uri=https://client-app.com/callback&response_type=token&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: oauth-authorization-server.com
~~~

**Parámetros clave:**

- `client_id`: identificador público de la aplicación.

- `redirect_uri`: URL de retorno tras la autorización.

- `response_type=token`: indica que se espera un token directamente.

- `scope`: permisos solicitados (por ejemplo openid profile).

- `state`: valor aleatorio que protege contra ataques CSRF.

#### 2. Inicio de sesión y consentimiento

El usuario inicia sesión en el proveedor OAuth y decide si concede los permisos solicitados.

Este paso es idéntico al flujo de código de autorización.

#### 3. Concesión del token de acceso

Si el usuario acepta, el servidor OAuth redirige al navegador a la `redirect_uri`.

Pero en lugar de enviar un código de autorización, el servidor envía directamente el token de acceso y otros datos como un fragmento de URL:

~~~
GET /callback#access_token=z0y9x8w7v6u5&token_type=Bearer&expires_in=5000&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: client-app.com
~~~

**Importante:**

- El token se encuentra en el fragmento de la URL (después de #), por lo que no se envía al servidor automáticamente.

- La aplicación debe usar un script en el navegador para extraer y almacenar el token de forma segura.

#### 4. Llamada a la API

Una vez extraído el token, la aplicación puede usarlo para realizar solicitudes a la API del proveedor OAuth:

~~~
GET /userinfo HTTP/1.1
Host: oauth-resource-server.com
Authorization: Bearer z0y9x8w7v6u5
~~~

En este caso, la llamada también se realiza desde el navegador, a diferencia del flujo de código de autorización donde se hace servidor a servidor.

#### 5. Entrega de los recursos

El servidor valida que el token sea válido y que pertenezca a la aplicación. Si todo es correcto, devuelve los datos solicitados:

~~~
{
    "username":"carlos",
    "email":"carlos@carlos-montoya.net"
}
~~~

La aplicación puede usar esta información para autenticar al usuario, por ejemplo, iniciar su sesión dentro de la aplicación.