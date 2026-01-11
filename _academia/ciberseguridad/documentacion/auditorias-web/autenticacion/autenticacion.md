---
title: Autenticación
description: Qué son, tipos y cómo funcionan las vulnerabilidades en la autenticación.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [autenticacion]
---

# Vulnerabilidades de autenticación

## Que es la autenticación

La autenticación es el proceso mediante el cual se comprueba la identidad de una persona que intenta acceder a un sitio. En internet, cualquier usuario puede intentar conectarse a una aplicación web, por lo que es fundamental asegurarse de que quien dice ser un usuario legítimo realmente lo sea.

En términos técnicos, la autenticación consiste en verificar uno o más factores de autenticación, es decir, pruebas que demuestran la identidad del usuario. Existen tres tipos principales:

- **Algo que sabes** (factor de conocimiento):  
Es información que solo el usuario debería conocer, como una contraseña o la respuesta a una pregunta de seguridad.    

    Ejemplo: una clave secreta para iniciar sesión.

- **Algo que tienes** (factor de posesión):  
Es un objeto físico que el usuario posee, como un teléfono móvil, una tarjeta o un dispositivo que genera códigos de seguridad (token).  

    Ejemplo: un código enviado por SMS al móvil del usuario.

- **Algo que eres o haces** (factor inherente):  
Se basa en características físicas o de comportamiento del usuario.  

    Ejemplo: huella dactilar, reconocimiento facial o la forma de teclear.

### Cuál es la diferencia entre autenticación y autorización?

Es importante no confundir **autenticación** con **autorización**:

- La **Autenticación** responde a la pregunta:  
“¿Quién eres?”  
Verifica la identidad del usuario.

- La **Autorización** responde a la pregunta:  
“¿Qué puedes hacer?”  
Determina qué acciones o recursos están permitidos para ese usuario.

Ambos procesos son esenciales, pero cumplen funciones diferentes dentro de la seguridad de una aplicación web.

## Mentalidad del atacante

En la práctica, el razonamiento suele seguir este orden:

- Confirmar que existen usuarios válidos (enumeración).

- Reducir o evitar los controles automáticos (rate limit, CAPTCHA).

- Probar credenciales de forma eficiente (diccionario, reutilización).

- Buscar fallos lógicos que permitan saltarse la autenticación.

- Aprovechar funcionalidades auxiliares como el reset de contraseña o el MFA.

Entender esta mentalidad ayuda a priorizar las pruebas durante una auditoría.

## ¿Cómo surgen las vulnerabilidades de autenticación?

Las vulnerabilidades de autenticación aparecen cuando un sitio no verifica correctamente la identidad de los usuarios. Como la autenticación es la primera barrera de seguridad de una aplicación, cualquier error en este proceso puede permitir que un atacante acceda sin permiso a cuentas o funciones protegidas.

Estas vulnerabilidades suelen surgir porque el sistema de autenticación es débil o porque está mal diseñado e implementado.

En la práctica, la mayoría de los problemas de autenticación se originan de dos formas principales:

1. **Protección insuficiente contra ataques de fuerza bruta**

    Un ataque de fuerza bruta consiste en probar muchas combinaciones de contraseñas hasta encontrar la correcta.

    Si un sistema de autenticación no limita los intentos de inicio de sesión ni detecta comportamientos sospechosos, un atacante puede probar contraseñas repetidamente hasta acceder a una cuenta.

2. **Errores lógicos o mala implementación (“autenticación rota”)**

    A veces, el problema no está en la contraseña, sino en la lógica del sistema, es decir, en las reglas que el sitio sigue para decidir si un usuario está autenticado o no.

    Una falla lógica ocurre cuando el sitio se comporta de forma distinta a la esperada debido a errores en el diseño o en el código.  
    En el contexto de la autenticación, estos errores pueden permitir que un atacante evite por completo el proceso de verificación de identidad. A este tipo de situación se le suele llamar autenticación rota.

    Aunque los errores lógicos pueden aparecer en muchas partes de una aplicación, cuando afectan a la autenticación el impacto es especialmente grave, porque permiten acceder al sistema sin demostrar quién eres.

## ¿Cuál es el impacto de la autenticación vulnerable?

Las vulnerabilidades de autenticación pueden tener consecuencias muy graves para la seguridad de una aplicación. Cuando un atacante consigue acceder a una cuenta sin autorización, deja de estar limitado por las protecciones públicas del sitio y pasa a operar como si fuera un usuario legítimo.

El impacto dependerá del tipo de cuenta comprometida, pero incluso el acceso a una cuenta con pocos permisos puede abrir la puerta a ataques más complejos.

## Superficie de ataque en autenticación

La autenticación no se limita al formulario de inicio de sesión. Durante una auditoría deben revisarse todos los puntos donde se gestiona identidad, incluyendo:

- Inicio de sesión.

- Registro de usuarios.

- Recuperación de contraseña.

- Cambio de contraseña.

- Autenticación multifactor (MFA).

Cada uno introduce lógica propia y, por tanto, posibles vulnerabilidades.

## Vulnerabilidades en los mecanismos de autenticación

En una aplicación, la autenticación puede implicar varias funcionalidades distintas, como formularios de inicio de sesión, sistemas de verificación adicional o métodos alternativos para identificarse. Cada uno introduce su propia lógica y, por tanto, sus propios riesgos.

Las vulnerabilidades pueden clasificarse en dos grandes grupos:

- **Vulnerabilidades generales**, que pueden aparecer en distintos mecanismos de autenticación, como errores en la lógica de validación o controles insuficientes.

- **Vulnerabilidades específicas**, que dependen del tipo de autenticación implementado y de cómo funciona.

En particular, existen áreas donde las vulnerabilidades son especialmente comunes:

- [**Inicio de sesión basado en contraseñas**](): mecanismos tradicionales que dependen de un nombre de usuario y una contraseña.

- [**Autenticación multifactor**](): sistemas que combinan más de una prueba de identidad, como contraseña y código temporal.

- [**Otros mecanismos de autenticación**](): métodos alternativos que no encajan en los dos grupos anteriores.

Cada una de estas áreas presenta riesgos distintos que deben analizarse de forma separada.

### Vulnerabilidades en los mecanismos de autenticación de terceros

Muchas aplicaciones permiten iniciar sesión usando servicios externos, como cuentas de Google, Facebook o GitHub.  
Este tipo de autenticación suele implementarse mediante OAuth.

[OAuth]() es un protocolo que permite a una aplicación verificar la identidad de un usuario sin manejar directamente su contraseña.  
En lugar de eso, la aplicación confía en un proveedor externo (por ejemplo, Google), que autentica al usuario y devuelve un token.

> Un token es un valor temporal que indica que el usuario ya ha sido autenticado por el proveedor externo.

Aunque OAuth reduce el manejo directo de contraseñas, no elimina los riesgos.  
Una implementación incorrecta puede permitir:

- Iniciar sesión como otro usuario
- Reutilizar tokens
- Omitir validaciones críticas durante el flujo de autenticación

Por ello, los mecanismos de autenticación de terceros introducen riesgos propios que deben analizarse de forma independiente.

## Flujo de pruebas

Un orden lógico de auditoría ayuda a evitar ruido innecesario y a detectar fallos reales:

1. Identificar todos los puntos de autenticación.

2. Probar enumeración de usuarios en cada uno.

3. Analizar respuestas, códigos HTTP y tiempos.

4. Evaluar protecciones contra automatización.

5. Probar fuerza bruta controlada.

6. Revisar lógica de flujos alternativos (reset, MFA).

7. Comprobar el canal de autenticación (HTTP/HTTPS).

## Vulnerabilidades frecuentes en la práctica

Durante auditorías reales es común encontrar:

- Mensajes de error distintos según si el usuario existe o no.

- Rate limit solo aplicado al login, pero no al reset.

- CAPTCHA implementado solo en el frontend.

- MFA aplicado únicamente al primer login.

- Tokens de reset reutilizables o sin expiración.

Estos fallos suelen pasar desapercibidos en revisiones superficiales.

## Relación con otras áreas de seguridad

Las vulnerabilidades de autenticación están estrechamente relacionadas con:

- **Gestión de sesión**: cookies, tokens, reutilización.

- **JWT y OAuth**: tokens mal gestionados.

- **Configuración:** flag Secure, flag HttpOnly.

- **Ingeniería social**: phishing y MITM.

## Cómo proteger los mecanismos de autenticación

Proteger los mecanismos de autenticación es una de las tareas más importantes en la seguridad de una aplicación. La autenticación es compleja y, si no se diseña e implementa con cuidado, es fácil introducir errores que permitan a un atacante acceder sin autorización.

Aunque no existe una lista completa de medidas que cubra todos los escenarios posibles, sí hay una serie de principios generales que ayudan a prevenir las vulnerabilidades de autenticación más comunes.

### Proteger las credenciales de los usuarios

Las credenciales son los datos que permiten iniciar sesión, como el nombre de usuario y la contraseña. Incluso el sistema más seguro falla si estas credenciales se exponen.

Es fundamental:

- No enviar credenciales mediante conexiones sin cifrar (por ejemplo, HTTP).

- Usar HTTPS, que cifra la información para que no pueda ser leída por terceros.

- Forzar la redirección automática de HTTP a HTTPS.

- Evitar que nombres de usuario o correos electrónicos se muestren públicamente o aparezcan en respuestas del servidor.

### No depender del comportamiento del usuario

Los usuarios suelen buscar la forma más cómoda de usar un sistema, aunque eso reduzca la seguridad. Por este motivo, la aplicación debe imponer comportamientos seguros siempre que sea posible.

Un ejemplo claro es la política de contraseñas. Las reglas tradicionales (como “usa un número y una mayúscula”) suelen generar contraseñas predecibles.  
Una alternativa más eficaz es usar verificadores de contraseñas que indiquen en tiempo real si una contraseña es fuerte o débil, permitiendo solo contraseñas con un nivel de seguridad alto.

### Evitar la enumeración de usuarios

La enumeración de usuarios ocurre cuando el sistema revela si un nombre de usuario existe o no. Esto facilita enormemente los ataques de autenticación.

Para evitarlo:

- Usar mensajes de error genéricos e idénticos, independientemente de si el usuario existe.

- Devolver siempre el mismo código de estado HTTP.

- Mantener tiempos de respuesta similares en todos los casos.

- Incluso saber que una persona tiene una cuenta puede ser información sensible.

### Protegerse contra ataques de fuerza bruta

Un ataque de fuerza bruta consiste en probar muchas combinaciones de contraseñas hasta encontrar la correcta.

Para dificultarlo:

- Limitar el número de intentos de inicio de sesión por dirección IP.

- Evitar que los atacantes puedan ocultar o cambiar fácilmente su IP.

- Solicitar pruebas adicionales, como un CAPTCHA, tras varios intentos fallidos.

Aunque estas medidas no eliminan por completo el riesgo, hacen que el ataque sea más lento y menos atractivo.

### Revisar cuidadosamente la lógica de autenticación

La lógica de autenticación son las reglas que determinan si un usuario está autenticado o no. Errores simples en esta lógica pueden permitir que un atacante la eluda por completo.

Es imprescindible:

- Auditar el código con atención.

- Verificar que todas las comprobaciones se realizan correctamente.

- Asumir que una verificación que puede saltarse es casi tan peligrosa como no tener ninguna.

### No olvidar las funciones relacionadas con la autenticación

La seguridad no debe centrarse solo en la página de inicio de sesión. Funciones como:

- Restablecer contraseña

- Cambiar contraseña

- Crear cuentas nuevas

también son superficies de ataque y deben protegerse con el mismo nivel de rigor que el inicio de sesión principal.

### Implementar correctamente la autenticación multifactor

La autenticación multifactor (MFA) utiliza más de un tipo de prueba para verificar la identidad del usuario. Bien implementada, es mucho más segura que usar solo una contraseña.

Puntos clave:

- Verificar varias veces el mismo factor no es MFA real.

- Enviar códigos por correo electrónico sigue siendo, en esencia, un solo factor.

- La autenticación por SMS añade un segundo factor, pero puede ser vulnerable a ataques como el intercambio de SIM.

- La opción más segura suele ser usar aplicaciones o dispositivos dedicados que generan códigos.

Además, la lógica que valida estos factores adicionales debe revisarse con el mismo cuidado que la autenticación principal.

## FuzzLists

Lista de payloads para realizar ataques de enumeración y fuerza bruta:

- [Nombres de usuarios PortSwigger](https://portswigger.net/web-security/authentication/auth-lab-usernames)
- [Contraseñas PortSwigger](https://portswigger.net/web-security/authentication/auth-lab-passwords)

## Ataques relacionados

Lista de enlaces con ataques relacionados:

- [Eludir las defensas comunes de SSRF](https://portswigger.net/web-security/ssrf#circumventing-common-ssrf-defenses)
- [CORS](https://portswigger.net/web-security/cors#errors-parsing-origin-headers)