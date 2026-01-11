---
title: Vulnerabilidades en la autenticación multifactor
description: Qué son, tipos y cómo funcionan las vulnerabilidades en la autenticación multifactor.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/autenticacion-multifactor/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [autenticacion]
---

## Códigos enviados por SMS

Un enfoque de autenticación multifactor común consiste en enviar el código de verificación al teléfono móvil del usuario mediante un mensaje SMS.

Aunque este método cumple técnicamente con el concepto de segundo factor, presenta debilidades importantes:

- El código se transmite por la red telefónica

- Puede ser interceptado en ciertos escenarios

- Es vulnerable a ataques de intercambio de SIM (SIM swapping)

En un ataque de SIM swapping, el atacante consigue que el operador telefónico le asigne el número de la víctima a una nueva tarjeta SIM. A partir de ese momento, recibe todos los mensajes SMS, incluidos los códigos de verificación.

Por este motivo, el SMS se considera uno de los métodos de 2FA menos seguros.

## MFA incompleto o mal aplicado

Un error frecuente ocurre cuando el sistema solicita:

- Usuario y contraseña

- Código de verificación en una página posterior

pero no valida correctamente que el segundo paso se haya completado.

En estos casos, tras introducir la contraseña, el usuario ya tiene una sesión parcialmente autenticada.
Durante una auditoría, es importante comprobar si es posible acceder directamente a páginas “solo para usuarios autenticados” sin completar el segundo factor.

Si esto ocurre, el 2FA puede eludirse por completo.

## Lógica defectuosa de verificación del segundo factor

Otro fallo crítico ocurre cuando el sistema no verifica que el mismo usuario complete ambos pasos del proceso.

Un ejemplo típico es el siguiente flujo:

1. El usuario introduce sus credenciales:

~~~
POST /login-steps/first HTTP/1.1
Host: vulnerable-website.com
...
username=carlos&password=qwerty
~~~

2. El servidor asigna una cookie asociada a la cuenta:

~~~
HTTP/1.1 200 OK
Set-Cookie: account=carlos

GET /login-steps/second HTTP/1.1
Cookie: account=carlos
~~~

3. En el segundo paso, el código 2FA se valida usando esa cookie:

~~~
POST /login-steps/second HTTP/1.1
Host: vulnerable-website.com
Cookie: account=carlos
...
verification-code=123456
~~~

En este caso, un atacante podría iniciar sesión usando sus propias credenciales pero luego cambiar el valor de la cookie `account` a cualquier nombre de usuario arbitrario al enviar el código de verificación.`

~~~
POST /login-steps/second HTTP/1.1
Host: vulnerable-website.com
Cookie: account=victim-user
...
verification-code=123456
~~~

Esto permitiría acceder a cuentas de otros usuarios sin conocer su contraseña, lo que convierte este fallo en extremadamente crítico.

## Códigos de verificación 2FA de fuerza bruta

Los códigos de verificación suelen ser números de 4 o 6 dígitos, lo que significa que existen muy pocas combinaciones posibles.

Si el sistema no limita adecuadamente los intentos, un atacante puede probar todas las combinaciones en poco tiempo.

Algunos sitios intentan mitigar esto cerrando la sesión tras varios intentos fallidos. Sin embargo, esta protección suele ser insuficiente si:

- El proceso puede automatizarse

- El estado de la sesión se reinicia fácilmente

- No existe un límite global por usuario o por token

En estos casos, la fuerza bruta del código 2FA sigue siendo viable.