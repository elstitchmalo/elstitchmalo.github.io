---
title: OpenID
description: Como funciona OpenID.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/openid/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [OpenID]
---

# Conexión OpenID

OpenID Connect es un estándar que permite a una aplicación comprobar de forma segura quién es un usuario, utilizando un servicio externo de autenticación (por ejemplo, “Iniciar sesión con Google”).

Para entenderlo fácilmente:

- OAuth nació para dar permiso a una aplicación para acceder a datos (por ejemplo, leer tu correo).

- OpenID Connect se creó después para resolver un problema concreto: identificar al usuario de forma fiable, no solo pedir permisos.

En otras palabras, OpenID Connect añade una capa de identidad sobre OAuth para que el inicio de sesión sea claro, uniforme y más seguro.

## ¿Por qué OAuth no era suficiente para autenticación?

OAuth fue diseñado para autorizar acceso a recursos, no para autenticar usuarios. Aun así, muchos sitios lo usaron como si fuera un sistema de login:

1. Pedían permiso para leer datos básicos del usuario.

2. Si el permiso era concedido, asumían que el usuario estaba autenticado.

Este enfoque tenía varios problemas:

- La aplicación no sabía cómo ni cuándo el usuario se había autenticado.

- Cada proveedor usaba reglas distintas (endpoints, permisos, formatos).

- No había una forma estándar de pedir información de identidad.

## Qué añade OpenID Connect

OpenID Connect soluciona estos problemas añadiendo:

- Ámbitos (scopes) estándar, iguales para todos los proveedores.

- Un nuevo tipo de respuesta llamado `id_token`, que contiene información sobre la identidad del usuario.

- Un formato común para los datos del usuario, llamados claims (reclamaciones).

Esto hace que la autenticación sea:

- Más predecible

- Más fácil de implementar correctamente

- Menos propensa a errores de seguridad

### Roles en OpenID Connect (explicados de forma simple)

- Parte que confía (Relying Party):   
La aplicación que quiere saber quién es el usuario (por ejemplo, una tienda online).

- Usuario final:  
La persona que inicia sesión.

- Proveedor de OpenID:  
El servicio que autentica al usuario (por ejemplo, Google, Microsoft, etc.).

### Claims y scopes (ámbitos)

- Un claim es un dato sobre el usuario en formato `clave:valor`.

    Ejemplo:

    ~~~
    "family_name": "Montoya"
    ~~~

- Un scope indica qué tipo de datos se están solicitando.

OpenID Connect define scopes estándar:

- `openid` (obligatorio)
- `profile`
- `email`
- `address`
- `phone`

Por ejemplo:

- Solicitar `openid profile` permite leer datos como nombre, fecha de nacimiento, etc.

### El id_token: la pieza clave

El `id_token` es un JWT (JSON Web Token):

- Es un texto firmado criptográficamente.
- Contiene información sobre:
    - Quién es el usuario
    - Cuándo se autenticó
    - Qué proveedor realizó la autenticación

La firma criptográfica permite verificar que los datos no han sido modificados.

Ventajas principales:

- No hace falta pedir los datos del usuario en una segunda petición.
- Mejora el rendimiento.
- Aporta más garantías de integridad que OAuth básico.

Importante:

Aunque la firma mejora la seguridad, las claves públicas para verificarla suelen estar accesibles públicamente (por ejemplo en `/.well-known/jwks.json`), por lo que no elimina todos los ataques posibles, especialmente si la implementación es débil.

Ademas, OAuth admite varios tipos de respuesta, por lo que es perfectamente aceptable que una aplicación cliente envíe una solicitud de autorización con un tipo de respuesta OAuth básico y un `id_token` tipo de respuesta de OpenID Connect:

~~~
response_type=id_token token
response_type=id_token code
~~~

En este caso, se enviarán al mismo tiempo a la aplicación cliente un token de identificación y un código o token de acceso.

## Identificar si una aplicación usa OpenID Connect

Puedes detectarlo comprobando:

- Si la solicitud de autorización incluye el scope obligatorio openid.
- Si el tipo de respuesta incluye `id_token`.
- Si existe un archivo accesible en:

~~~
/.well-known/openid-configuration
~~~

Incluso si no es evidente, algunos proveedores soportan OpenID Connect aunque no lo documenten claramente.

## Vulnerabilidades de OpenID Connect

Aunque OpenID Connect es un estándar más estricto y mejor definido que OAuth básico, no es inmune a vulnerabilidades. Esto se debe a que OpenID Connect no reemplaza OAuth, sino que se construye sobre él. Por tanto, hereda muchos de sus riesgos, especialmente cuando las implementaciones no siguen buenas prácticas de seguridad.

Además, OpenID Connect introduce funcionalidades adicionales que, si se configuran de forma insegura, pueden abrir nuevas superficies de ataque. Las vulnerabilidades que veremos no suelen estar en el estándar en sí, sino en cómo lo implementan los proveedores y las aplicaciones cliente.

### Registro dinámico de clientes sin protección

OpenID Connect permite que una aplicación se registre automáticamente ante un proveedor de identidad mediante un proceso llamado registro dinámico de clientes.

En este proceso:

- La aplicación envía una petición `POST` a un endpoint especial (por ejemplo, `/registration`).
- Incluye un objeto JSON con información sobre la aplicación, como:
    - URLs a las que el proveedor puede redirigir al usuario (`redirect_uris`)
    - Nombre de la aplicación
    - Direcciones web (URI) con recursos adicionales

Este mecanismo debería estar protegido, es decir, el proveedor debería exigir que la aplicación se autentique antes de poder registrarse.

#### El problema de seguridad

Algunos proveedores permiten este registro sin autenticación previa. Esto significa que:

- Cualquier persona puede registrar una aplicación falsa.
- Un atacante puede controlar los valores enviados al proveedor.

Esto es peligroso porque algunos de esos valores son URLs. Si el proveedor accede a ellas automáticamente, el atacante puede forzar al servidor a realizar peticiones internas o externas no deseadas.

Este tipo de ataque se conoce como SSRF (Server-Side Request Forgery), que ocurre cuando un servidor realiza solicitudes HTTP controladas por un atacante.

En este caso concreto, se habla de SSRF de segundo orden, porque:

- El valor malicioso se almacena primero.
- El ataque ocurre más tarde, cuando el servidor utiliza ese valor.

### Permitir solicitudes de autorización por referencia (`request_uri`)

Normalmente, en OAuth y OpenID Connect, los parámetros de autenticación (como `client_id`, `redirect_uri`, etc.) se envían directamente en la URL.

Algunos proveedores permiten una alternativa:

- En lugar de enviar todos los parámetros, se envía uno solo: `request_uri`.
- Este parámetro apunta a un JWT (JSON Web Token) externo que contiene el resto de los datos.

Riesgos de esta funcionalidad

Este comportamiento introduce dos problemas importantes:

1. **Nuevo vector de SSRF**  
Si el servidor descarga el JWT desde una URL controlada por el atacante, puede ser obligado a realizar peticiones arbitrarias.

2. **Validación inconsistente**  
Algunos servidores validan bien los parámetros cuando vienen en la URL, pero no aplican los mismos controles cuando esos valores están dentro de un JWT.

Esto puede permitir:

- Saltarse restricciones sobre `redirect_uri`
- Usar valores no autorizados que normalmente serían bloqueados

#### Cómo identificar estas funcionalidades

Para saber si un proveedor soporta estas características:

- Revisar el archivo de configuración accesible públicamente.
- Buscar opciones como:
    - `request_uri_parameter_supported`
- Probar manualmente si el proveedor acepta el parámetro `request_uri`, incluso si no aparece en la documentación.

Es común que estas funciones estén habilitadas sin estar claramente documentadas, lo que aumenta el riesgo.