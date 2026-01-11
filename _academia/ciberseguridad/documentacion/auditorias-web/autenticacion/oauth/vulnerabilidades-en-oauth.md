---
title: Vulnerabilidades en OAuth
description: Diferentes vulnerabilidades en OAuth.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/oauth/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [OAuth]
---

# Vulnerabilidades en la aplicación cliente OAuth

Aunque los proveedores OAuth suelen ser seguros, la aplicación cliente puede implementar OAuth de forma incorrecta.

## Dónde pueden aparecer vulnerabilidades en OAuth

Las vulnerabilidades pueden surgir en dos lugares distintos:

1. En la aplicación cliente (la web o app que usa OAuth).

2. En el propio servicio OAuth (el proveedor).

Ambos deben analizarse por separado.

### Uso inseguro de la concesión implícita

El concesión implícita envía el token de acceso al navegador como parte de la URL.
Esto se diseñó para aplicaciones de una sola página (SPA), pero a veces se usa incorrectamente en aplicaciones web tradicionales.

Problema clave:

- El servidor confía en los datos que recibe del navegador sin poder verificarlos.

- Un atacante puede modificar esos datos y suplantar a otro usuario.

Ejemplo sencillo:

Si el servidor recibe un token y un ID de usuario sin comprobar que realmente coinciden, un atacante puede enviar datos falsos y acceder a la cuenta de otra persona.

### Protección CSRF insuficiente (parámetro `state`)

CSRF (Cross-Site Request Forgery) es un ataque que engaña al navegador del usuario para ejecutar acciones no deseadas.

En OAuth, el parámetro `state` sirve como token de protección CSRF.
Debe ser un valor impredecible vinculado a la sesión del usuario.

Si falta el parámetro `state`:

- Un atacante puede iniciar un flujo OAuth propio.

- Luego engañar al usuario para que lo complete.

- Esto puede provocar secuestro de cuentas o inicio de sesión forzado.

Ejemplo práctico:

Un atacante puede vincular su cuenta de redes sociales a la cuenta de la víctima en una aplicación vulnerable.

### Fuga de códigos de autorización y tokens de acceso

Esta es una de las vulnerabilidades más graves en OAuth.

Durante el flujo OAuth:

- El código o token se envía al navegador.

- Luego se redirige a la URL indicada en `redirect_uri`.

Si el servidor OAuth no valida correctamente esa URL, un atacante puede:

- Usar un `redirect_uri` bajo su control.

- Recibir el código o token de la víctima.

- Acceder a sus datos o iniciar sesión como ella.

Incluso mecanismos como `state` o `nonce` no siempre evitan esto si el atacante puede generar valores válidos desde su propio navegador.

Los servidores más seguros comparan el `redirect_uri` usado al intercambiar el código con el original, lo que evita este ataque.

#### Validación incorrecta del `redirect_uri`

Para reducir el riesgo de ataques, se recomienda que una aplicación cliente registre previamente una lista blanca de sus URI de redirección (también llamadas callback URLs) cuando se integra con un servicio OAuth.

> ¿Qué es una lista blanca?
Es un conjunto de direcciones permitidas explícitamente. Cualquier valor que no esté en esa lista se rechaza.

De esta forma, cuando el servicio OAuth recibe una solicitud de autorización, puede comprobar que el valor del parámetro `redirect_uri` coincide exactamente con una de las direcciones autorizadas.
Si el valor apunta a un dominio externo o no autorizado, el servidor debería devolver un error y detener el flujo.

Sin embargo, no todas las validaciones están bien implementadas, y en la práctica existen formas de eludir algunos controles.

**Cómo analizar la validación de redirect_uri durante una auditoría**

Al revisar la seguridad de un flujo OAuth, es importante probar cómo se valida el parámetro redirect_uri, en lugar de asumir que el control es correcto.

Esto implica modificar el valor del parámetro y observar cómo responde el servidor.

- **Validaciones débiles basadas solo en el dominio**

    Algunas implementaciones solo comprueban que la URL empiece por una cadena concreta, como un dominio autorizado, por ejemplo:

    ~~~
    https://client-app.com
    ~~~

    Si la validación se limita a esto, el servidor puede aceptar muchas variaciones no previstas.

    - En estos casos, conviene probar:

    - Añadir o eliminar rutas (`/path`)

    - Incluir parámetros de consulta (`?param=value`)

    - Añadir fragmentos de URL (`#section`)

    El objetivo es identificar qué partes de la URL se pueden modificar sin que el servidor rechace la solicitud.

- **Confusión en el análisis de la URL**

    En algunos escenarios, es posible añadir datos extra al `redirect_uri` que se interpretan de forma distinta según el componente que procese la URL (por ejemplo, el servidor OAuth, un proxy o el navegador).

    Esto puede aprovecharse usando construcciones de URL poco comunes, como:

    ~~~
    https://default-host.com&@foo.evil-user.net#@bar.evil-user.net/
    ~~~

    Aunque visualmente parece una sola dirección, distintos sistemas pueden interpretarla de forma diferente, lo que a veces permite redirigir información sensible (como códigos o tokens OAuth) a un dominio controlado por un atacante.

- **Contaminación de parámetros**

    En algunos casos poco comunes, los servidores web no manejan correctamente parámetros duplicados en una solicitud HTTP.
    
    A esto se le llama contaminación de parámetros (parameter pollution).
    
    > ¿Qué significa esto?  
    Ocurre cuando un mismo parámetro aparece más de una vez en la URL y el servidor:
    >- Usa solo el primero
    >- Usa solo el último
    >- O combina los valores de forma inesperada

    En el contexto de OAuth, esto puede ser peligroso si el servidor OAuth no gestiona bien múltiples valores de `redirect_uri`.

    Ejemplo:

    ~~~
    https://oauth-authorization-server.com/?client_id=123&redirect_uri=client-app.com/callback&redirect_uri=evil-user.net
    ~~~

    Aquí se envían dos valores distintos para redirect_uri:

    - Uno legítimo (`client-app.com`)
    - Uno controlado por el atacante (`evil-user.net`)

    Si el servidor:

    - Valida solo el primer `redirect_uri`, pero
    - Usa el segundo para realizar la redirección real,

    entonces el atacante podría recibir el código de autorización o el token, aunque la validación aparentemente haya pasado.

- **Tratamiento especial de `localhost` en `redirect_uri`**

    Durante el desarrollo, es muy común que las aplicaciones usen direcciones como:

    ~~~
    http://localhost
    http://localhost:3000
    ~~~

    Por esta razón, algunos servidores OAuth implementan reglas especiales para permitir `localhost` como URI de redirección.

    El problema aparece cuando estas reglas no se restringen correctamente en producción.

    En algunos casos, el servidor OAuth permite cualquier URI que empiece por la palabra `localhost`, sin comprobar que sea realmente el dominio correcto.

    Por ejemplo, el servidor podría aceptar:

    ~~~
    http://localhost.evil-user.net
    ~~~

    Aunque no es realmente `localhost`, sino un dominio externo controlado por un atacante.

    Esto ocurre cuando la validación se basa únicamente en comprobar si la URL comienza con una cadena concreta, en lugar de analizar correctamente el dominio.

Es importante tener en cuenta que no debemos limitar las pruebas a probar el parámetro `redirect_uri` de forma aislada. En la práctica, a menudo se necesitará experimentar con diferentes combinaciones de cambios en varios parámetros. A veces, cambiar un parámetro puede afectar la validación de otros. Por ejemplo, cambiar el `response_modede` de `query` a `fragment` puede alterar por completo el análisis de `redirect_uri`, lo que permite enviar URI que de otro modo estarían bloqueadas. Asimismo, si se observa que el modo de respuesta `web_message` es compatible, esto suele permitir una mayor variedad de subdominios en `redirect_uri`.

#### Robo de códigos y tokens de acceso a través de una página proxy

Aunque muchas aplicaciones protegen bien el parámetro `redirect_uri` (la dirección a la que el sistema redirige al usuario tras autenticarse), a veces es posible manipularlo para apuntar a otras páginas dentro del mismo dominio permitido.

Muchas aplicaciones usan rutas como `/oauth/callback` para recibir la respuesta de OAuth. Aunque esta ruta parezca limitada, a veces es posible abusar de trucos de navegación de directorios, como `../`, para acceder a otras rutas del mismo dominio.

Por ejemplo, una URL como:

~~~
https://client-app.com/oauth/callback/../../example/path
~~~

puede ser interpretada por el servidor como:

~~~
https://client-app.com/example/path
~~~

Esto permite al atacante redirigir el flujo OAuth a otras páginas internas. Una vez identificadas esas páginas, deben revisarse en busca de vulnerabilidades que permitan leer o reenviar información sensible, como:

- Parámetros de la URL (usados en el flujo de código de autorización).

- Fragmentos de URL (usados en el flujo implícito).

Una vulnerabilidad especialmente útil es la redirección abierta, que permite enviar al usuario (junto con su código o token) a un sitio externo controlado por el atacante. Esa página maliciosa puede ejecutar scripts para robar la información.

En el flujo implícito, el impacto es mayor: el token de acceso se entrega directamente al navegador. Si un atacante lo roba, no solo puede iniciar sesión como la víctima, sino también hacer llamadas directas a la API del servicio OAuth, accediendo a datos que la interfaz web normal quizá no expone.

Aunque las redirecciones abiertas son una forma muy común de robar códigos o tokens OAuth, no son la única opción. Cualquier vulnerabilidad que permita leer información de la URL y enviarla a un dominio externo puede servir para el mismo objetivo.

Esto incluye fallos en JavaScript, vulnerabilidades XSS y vulnerabilidades de inyección HTML. Todas ellas pueden aprovecharse para extraer el código de autorización o el token de acceso que OAuth devuelve tras la autenticación del usuario.

- JavaScript peligroso que maneja parámetros de consulta y fragmentos de URL

    Muchas aplicaciones usan JavaScript para leer información de la URL, como:
    
    -  Parámetros de consulta (`?code=...`)
    - Fragmentos de URL (`#access_token=...`)

    El problema aparece cuando estos scripts:

    - Procesan esos valores sin validarlos.
    - Los envían a otros scripts o servicios externos.
    - Los muestran en la página de forma insegura.

    Un ejemplo típico son los scripts de mensajería web (como sistemas de comunicación entre ventanas o iframes). Si están mal diseñados, pueden actuar como un canal involuntario para transportar el token desde la URL hasta un dominio controlado por el atacante.

    En escenarios más complejos, el atacante puede encadenar varios scripts vulnerables (lo que se conoce como una cadena de gadgets) para mover el token paso a paso hasta filtrarlo fuera de la aplicación.

- Vulnerabilidades XSS

    Una vulnerabilidad XSS permite al atacante inyectar y ejecutar JavaScript en el navegador de la víctima.

    Aunque esto ya es grave por sí solo, tiene una limitación importante:

    - El atacante suele tener acceso solo mientras la víctima mantiene la pestaña abierta.
    - Las cookies de sesión suelen estar protegidas con `HTTPOnly`, lo que impide leerlas directamente con JavaScript.

    Sin embargo, si mediante XSS el atacante roba un código OAuth o un token de acceso, la situación cambia radicalmente:

    - El atacante puede iniciar sesión en su propio navegador, sin depender de la sesión de la víctima.
    - Esto le da mucho más tiempo para explorar la cuenta, acceder a datos y realizar acciones maliciosas.

    Por este motivo, combinar XSS con OAuth aumenta significativamente el impacto de la vulnerabilidad.

- Vulnerabilidades de inyección HTML

    Incluso cuando no es posible ejecutar JavaScript, por ejemplo debido a:

    - Políticas de seguridad de contenido (CSP).
    - Filtros estrictos de entrada.

    Una inyección HTML simple aún puede ser suficiente para robar el código OAuth.

    Si el atacante puede inyectar HTML en una página usada como `redirect_uri`, puede aprovechar el encabezado HTTP Referer. Este encabezado indica desde qué URL se originó una petición.

    Por ejemplo, al inyectar un elemento como:

    ~~~
    <img src="https://evil-user.net">
    ~~~

    algunos navegadores (como Firefox) enviarán al servidor externo:

    - La URL completa de la página actual.

    - Incluyendo la cadena de consulta, donde puede estar el código de autorización.

    De esta forma, el código OAuth se filtra sin necesidad de JavaScript.

### Validación de alcance defectuosa

En OAuth, cuando un usuario inicia sesión mediante un proveedor externo (como Google), debe aprobar qué datos puede usar la aplicación. Estos permisos se llaman alcances (scopes).
El token de acceso que se genera solo debería permitir acceder a los datos que el usuario aprobó explícitamente.

Sin embargo, si el servidor OAuth no valida correctamente estos alcances, un atacante puede conseguir un token con más permisos de los autorizados, lo que le permite acceder a información adicional del usuario sin su consentimiento.

#### Actualización indebida de alcance en el flujo de código de autorización

En el flujo de código de autorización, el intercambio del código por el token ocurre directamente entre servidores, lo que normalmente protege este paso frente a ataques externos.

Sin embargo, un atacante puede registrar su propia aplicación cliente con el proveedor OAuth.
Si el servidor OAuth está mal configurado, el atacante puede:

1. Solicitar un alcance limitado (por ejemplo, solo `email`).

2. Obtener un código de autorización tras el consentimiento del usuario.

3. En la solicitud de intercambio del código por el token, añadir nuevos scopes (como `profile`).

~~~
POST /token
Host: oauth-authorization-server.com
…
client_id=12345&client_secret=SECRET&redirect_uri=https://client-app.com/callback&grant_type=authorization_code&code=a1b2c3d4e5f6g7h8&scope=openid%20 email%20profile
~~~

Si el servidor no comprueba que esos nuevos scopes coinciden con los aprobados inicialmente, generará un token con permisos ampliados.  

~~~
{
    "access_token": "z0y9x8w7v6u5",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "openid email profile",
    …
}
~~~

El atacante podrá entonces usar ese token para acceder a datos adicionales del usuario.

#### Actualización indebida de alcance en el flujo implícito

En el flujo implícito, el token de acceso se envía directamente al navegador del usuario.
Esto lo hace más vulnerable, ya que:

- Un atacante puede robar el token (por ejemplo, mediante redirecciones o fallos en el cliente).

- El atacante puede reutilizar el token desde su propio navegador.

Una vez en posesión del token, el atacante puede enviar solicitudes al endpoint `/userinfo` y añadir manualmente nuevos `scopes`.

Si el servidor OAuth no valida que el scope solicitado coincida con el del token original, puede devolver información adicional sin requerir un nuevo consentimiento del usuario.

#### Registro de usuario no verificado

Cuando una aplicación usa OAuth para autenticación, confía en los datos del proveedor OAuth, como el correo electrónico del usuario.

El problema surge si el proveedor OAuth:

- Permite registrar cuentas sin verificar completamente los datos, por ejemplo, el email.

Un atacante puede:

1. Crear una cuenta en el proveedor OAuth usando el correo electrónico de la víctima.

2. Iniciar sesión en la aplicación cliente mediante OAuth.

3. La aplicación cliente confía en el email recibido y asume que se trata del usuario legítimo.

Esto puede permitir al atacante suplantar la identidad de la víctima.

## OAuth y OpenID Connect

Cuando OAuth se utiliza para autenticación (no solo para autorización), suele combinarse con [OpenID]() Connect.

Esta extensión añade mecanismos específicos para identificar al usuario, pero también introduce nuevos vectores de ataque si se implementa incorrectamente.

## Cómo prevenir vulnerabilidades de autenticación OAuth

OAuth es un mecanismo muy utilizado para permitir que los usuarios se autentiquen en una aplicación usando un servicio externo. Aunque es ampliamente adoptado, OAuth no es seguro por defecto: la especificación deja muchas decisiones críticas en manos de los desarrolladores.

Por este motivo, una validación incorrecta en cualquier parte del flujo OAuth puede introducir vulnerabilidades graves, tanto en el proveedor de OAuth como en la aplicación cliente. La seguridad del sistema completo depende de que ambas partes implementen controles adecuados.

### Medidas de seguridad para proveedores de OAuth

- **Validación estricta de redirect_uri**

    El parámetro `redirect_uri` indica a dónde se redirige al usuario tras autenticarse.

    El proveedor OAuth debe:

    - Exigir que cada aplicación registre previamente una lista exacta de URLs permitidas.

    - Comparar el `redirect_uri` recibido con estas URLs de forma exacta (byte a byte).

    - Evitar validaciones flexibles o por patrones, que podrían permitir acceder a otras rutas del mismo dominio.

    Esto impide que un atacante redirija el flujo OAuth a páginas internas vulnerables.

- **Uso obligatorio del parámetro `state`**

    El parámetro `state` es un valor aleatorio que se envía durante el inicio del flujo OAuth y se verifica al final.

    Debe:

    - Ser obligatorio.
    - Estar vinculado a la sesión del usuario.
    - Contener datos difíciles de adivinar.

    Esto protege contra ataques CSRF (ataques que fuerzan acciones sin consentimiento del usuario) y dificulta el uso de códigos de autorización robados.

- **Validación del token en el servidor de recursos**

    El servidor que recibe el token debe comprobar:

    - Que el token fue emitido para el mismo `client_id` que realiza la solicitud.
    - Que el scope (permisos) solicitados coincidan con los otorgados originalmente.

    Esto evita el uso indebido de tokens o la ampliación de permisos.

### Medidas de seguridad para aplicaciones cliente OAuth

- **Comprender correctamente el flujo OAuth**

    Muchas vulnerabilidades aparecen porque los desarrolladores no entienden bien:

    - Qué datos se intercambian.
    - En qué momento.
    - Qué puede manipular un atacante.

    Una implementación segura empieza por entender el protocolo.

- **Uso del parámetro `state`, incluso si no es obligatorio**

    Aunque algunos proveedores no lo exijan, el cliente siempre debería usar `state` para proteger a los usuarios frente a ataques de tipo CSRF.

- **Enviar `redirect_uri` tanto en `/authorization` como en `/token`**

    El cliente debe indicar el mismo redirect_uri:

    - Al iniciar la autorización.
    - Al intercambiar el código por el token.

    Esto ayuda al servidor OAuth a detectar manipulaciones.

- **Uso de PKCE en aplicaciones móviles y de escritorio**
    
    En aplicaciones nativas (móvil o escritorio):

    - No es posible mantener en secreto el `client_secret`.

    En estos casos se debe usar PKCE (Proof Key for Code Exchange), un mecanismo que protege el código de autorización frente a interceptaciones.

- **Validación correcta de `id_token` en OpenID Connect**
    
    Si se usa OpenID Connect:

    - El `id_token` debe validarse según los estándares de firma y cifrado.
    - No debe confiarse en él sin verificar su integridad y origen.

- **Evitar la filtración de códigos de autorización**

    Los códigos OAuth pueden filtrarse si:

    - Se cargan recursos externos (imágenes, scripts, CSS).
    - Se incluyen en JavaScript generado dinámicamente.

    Esto puede provocar que el código viaje en el encabezado `Referer` o se ejecute desde dominios externos.