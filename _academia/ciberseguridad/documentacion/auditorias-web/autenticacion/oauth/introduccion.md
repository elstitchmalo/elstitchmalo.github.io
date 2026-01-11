---
title: Introducción
description: Como funciona OAuth.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/oauth/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [OAuth]
---

# Vulnerabilidades de autenticación de OAuth 2.0

Cuando navegas por Internet, es muy común encontrar sitios que te permiten iniciar sesión usando una cuenta existente, como Google, Facebook o GitHub. Esta funcionalidad suele estar implementada mediante OAuth 2.0, un estándar muy utilizado para delegar accesos entre aplicaciones.

Desde el punto de vista de la seguridad, OAuth 2.0 resulta especialmente interesante porque:

- Está muy extendido, por lo que cualquier error afecta a muchos sistemas.

- Es complejo de implementar correctamente, lo que aumenta la probabilidad de fallos.

- Un error puede permitir a un atacante acceder a datos sensibles o incluso saltarse el proceso de autenticación.

## ¿Qué es OAuth?

OAuth es un marco de autorización. Esto significa que sirve para conceder permisos, no para autenticar usuarios (aunque hoy en día también se use con ese fin).

En términos simples, OAuth permite que:

- Una aplicación acceda a ciertos datos de un usuario almacenados en otro servicio.

- El usuario no tenga que compartir su contraseña con esa aplicación.

- El acceso esté limitado y controlado (por ejemplo, solo leer contactos, pero no modificar nada).

### Ejemplo sencillo

Imagina que una aplicación quiere acceder a tu lista de contactos de correo electrónico para sugerirte amigos.

Con OAuth:

- La aplicación pide permiso.

- Tú aceptas o rechazas.

- La aplicación recibe acceso solo a los contactos, no a toda tu cuenta.

Este mismo mecanismo se reutiliza para permitir que un usuario inicie sesión en un sitio web usando una cuenta que ya tiene en otro servicio.

> OAuth 2.0 no es una evolución directa de OAuth 1.0a; fue rediseñado desde cero y funciona de manera muy diferente.

## ¿Cómo funciona OAuth 2.0?

OAuth 2.0 define cómo interactúan tres actores principales:

1. **Aplicación cliente**  

    Es el sitio web o aplicación que quiere acceder a los datos del usuario.  

    Ejemplo: una tienda online que permite iniciar sesión con Google.

2. **Propietario del recurso**  

    Es el usuario dueño de los datos.

    Ejemplo: tú, como titular de una cuenta de Google.

3. **Proveedor de servicios OAuth**  

    Es el sistema que almacena los datos del usuario y gestiona los permisos.

    Proporciona:

    - Un servidor de autorización (emite permisos).

    - Un servidor de recursos (entrega los datos).

### Flujos o tipos de concesión

OAuth 2.0 puede implementarse de distintas formas llamadas flujos o [tipos de concesión](../../oauth/tipos-de-concesion).

En este contenido nos centraremos en los más comunes:

- Código de autorización

- Flujo implícito

Aunque difieren en detalles técnicos, ambos siguen una lógica general similar:

1. La aplicación cliente solicita acceso a determinados datos e indica qué flujo va a utilizar.

2. El usuario inicia sesión en el proveedor OAuth y autoriza explícitamente el acceso.

3. La aplicación recibe un token de acceso (una cadena secreta que demuestra que el usuario dio permiso).

4. La aplicación usa ese token para solicitar datos al servidor de recursos mediante una API.

Antes de analizar vulnerabilidades, es importante entender bien este proceso, ya que la mayoría de los fallos ocurren por una mala gestión de estos pasos.

### Autenticación con OAuth

Aunque OAuth fue diseñado para autorizar accesos, hoy en día se utiliza ampliamente para autenticar usuarios.

#### ¿Qué significa esto?

En lugar de crear un usuario y contraseña nuevos, el sitio web confía en un proveedor externo (como Google) para confirmar la identidad del usuario.

Desde la perspectiva del usuario:

- El resultado es similar al inicio de sesión único (SSO).

- Se accede al sitio sin crear nuevas credenciales.

En este material nos centraremos exclusivamente en las vulnerabilidades de seguridad de este uso de OAuth como sistema de autenticación.

#### Flujo típico de autenticación OAuth

Un proceso de autenticación basado en OAuth suele funcionar así:

1. El usuario selecciona “Iniciar sesión con una red social”.

2. La aplicación cliente solicita acceso a datos identificativos del usuario, como su dirección de correo electrónico.

3. Tras recibir un token de acceso, la aplicación consulta un endpoint específico (por ejemplo, /userinfo) para obtener esos datos.

4. La aplicación utiliza esa información como si fuera un nombre de usuario y trata el token de acceso como sustituto de una contraseña

#### Punto clave de seguridad

Si la aplicación confía incorrectamente en los datos recibidos o no valida bien el token, un atacante puede aprovecharlo para suplantar identidades.

## ¿Por qué aparecen vulnerabilidades en la autenticación OAuth?

OAuth es un estándar de autorización que permite a una aplicación acceder a datos de un usuario sin conocer su contraseña. Por ejemplo, cuando una web te permite “Iniciar sesión con Google”, normalmente está usando OAuth.

El problema es que la especificación de OAuth es intencionalmente flexible. Define solo los elementos mínimos necesarios para que el sistema funcione, pero deja muchas decisiones de seguridad en manos de los desarrolladores.

Esto significa que:

- Muchas configuraciones críticas son opcionales.

- La seguridad depende en gran medida de que el desarrollador elija correctamente esas opciones.

- Es fácil cometer errores si no se tiene experiencia con OAuth.

Además, OAuth no incluye muchas protecciones de seguridad por defecto. Funciones importantes como la validación estricta de datos o la protección frente a ataques comunes deben implementarse manualmente. Si esto se hace mal o se omite, aparecen vulnerabilidades.

Por último, algunos flujos de OAuth envían datos sensibles a través del navegador, como tokens de acceso. Esto aumenta el riesgo de que un atacante los intercepte o manipule.

## Cómo identificar el uso de OAuth en una aplicación

Detectar OAuth suele ser sencillo:

- Si una aplicación ofrece iniciar sesión usando otra cuenta externa (Google, Facebook, GitHub, etc.), casi con seguridad usa OAuth.

Una forma más técnica y fiable es analizar el tráfico HTTP con una herramienta como Burp Suite (un proxy que permite ver las solicitudes del navegador).

En cualquier flujo OAuth, la primera solicitud siempre se envía al endpoint de autorización (`/authorization`) y contiene parámetros característicos, como:

- `client_id`: identifica a la aplicación cliente.

- `redirect_uri`: URL a la que se redirige al usuario tras autenticarse.

- `response_type`: indica el tipo de flujo OAuth.

Ejemplo simplificado:

~~~
GET /authorization?client_id=12345&redirect_uri=https://client-app.com/callback&response_type=token&scope=openid%20profile&state=ae13d489bd00e3c24 HTTP/1.1
Host: oauth-authorization-server.com
~~~

## Reconocimiento del servicio OAuth

Antes de buscar vulnerabilidades, es importante entender cómo funciona el flujo OAuth concreto que usa la aplicación.

Pasos básicos de reconocimiento:

1. Observar todas las solicitudes HTTP que forman el flujo OAuth.

2. Identificar el proveedor OAuth (por ejemplo, Google o un proveedor propio).

3. Consultar su documentación pública, que suele detallar endpoints y configuraciones.

Además, muchos servidores OAuth exponen archivos de configuración estándar accesibles por HTTP, como:

- `/.well-known/oauth-authorization-server`

- `/.well-known/openid-configuration`

Estos archivos suelen devolver un JSON con información útil sobre funciones habilitadas, lo que puede revelar una superficie de ataque mayor de la esperada.