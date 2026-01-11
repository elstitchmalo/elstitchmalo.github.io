---
title: Ataques de fuerza bruta
description: Como funcionan los ataques de fuerza bruta.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/basada-en-contrasena/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [fuerza bruta]
---

Un ataque de fuerza bruta es una técnica mediante la cual un atacante intenta acceder a una cuenta probando muchas combinaciones posibles de credenciales (nombre de usuario y contraseña) hasta encontrar una válida. Este método se basa en la repetición y en la automatización, no en un acceso legítimo.

Estos ataques son especialmente efectivos cuando un sitio web no limita ni controla los intentos de inicio de sesión, o cuando revela información que ayuda al atacante a acertar más rápido. Por este motivo, los sistemas de autenticación basados únicamente en contraseñas suelen ser un objetivo frecuente.

## ¿Cómo funciona un ataque de fuerza bruta?

En lugar de probar manualmente, los atacantes utilizan herramientas automatizadas que envían miles o millones de solicitudes de inicio de sesión por segundo. Estas herramientas suelen apoyarse en:

- Listas de nombres de usuario comunes o filtrados.

- Diccionarios de contraseñas reales, no aleatorias.

- Reglas simples para modificar contraseñas conocidas.

La fuerza bruta no suele ser completamente aleatoria. Los atacantes usan lógica básica y conocimiento público para hacer intentos más probables, lo que aumenta mucho la tasa de éxito.

## Enumeración de nombres de usuario

Antes de atacar contraseñas, muchos ataques comienzan identificando usuarios válidos. Este proceso se conoce como enumeración de usuarios.

La enumeración de nombres de usuario ocurre cuando el sitio se comporta de forma diferente según si un usuario existe o no. 

Esto permite al atacante confirmar qué nombres de usuario son válidos. Por ejemplo, en el formulario de inicio de sesión al introducir un nombre de usuario válido pero una contraseña incorrecta, o en los formularios de registro al introducir un nombre de usuario ya utilizado. Esto reduce considerablemente el tiempo y el esfuerzo necesarios para forzar un inicio de sesión

Esto suele detectarse observando diferencias en:

- **Códigos de estado HTTP**: un código HTTP distinto puede indicar que el usuario existe.

- **Mensajes de error**: textos ligeramente diferentes según el error. A veces, el mensaje de error devuelto varía según si tanto el nombre de usuario como la contraseña son incorrectos o si solo lo es la contraseña.

- **Tiempos de respuesta**: respuestas más lentas pueden indicar que el sistema pasó a una verificación adicional, como comprobar la contraseña solo si el usuario existe.

Aunque estas diferencias pueden ser sutiles, un atacante puede detectarlas fácilmente.

Además, algunos sitios web divulgan información sin querer, por ejemplo:

- Perfiles visibles sin iniciar sesión. Muchas veces, el nombre usado en el perfil coincide con el nombre de usuario de inicio de sesión.

- Respuestas HTTP que contienen direcciones de correo electrónico.

- Información sobre usuarios administrativos o de soporte.

En muchas ocasiones, los nombres de usuario suelen ser fáciles de adivinar cuando siguen patrones previsibles, como:

- Direcciones de correo electrónico empresariales estándar (`nombre.apellido@compañia.com`).

- Formatos de nombre empresariales estándar (`nombre.apellido`).

- Usuarios privilegiados con nombres obvios como `admin` o `administrator`.

Todo esto permite al atacante construir una lista de usuarios válidos antes de atacar las contraseñas.

## Fuerza bruta de contraseñas

Una vez identificados usuarios válidos, el siguiente paso suele ser atacar las contraseñas.

Las contraseñas también pueden ser forzadas, pero su dificultad depende de su fortaleza. Muchos sitios aplican políticas de contraseñas, como exigir:

- Un mínimo de caracteres.

- Letras mayúsculas y minúsculas.

- Números y caracteres especiales.

Aunque estas reglas aumentan la seguridad en teoría, en la práctica los usuarios suelen adaptarlas de forma predecible. En lugar de usar contraseñas realmente aleatorias, hacen pequeños cambios fáciles de recordar.

Esto crea patrones comunes que los atacantes aprovechan, especialmente cuando las contraseñas deben cambiarse periódicamente. En lugar de crear una nueva contraseña, los usuarios suelen modificar ligeramente la anterior.

Por ejemplo, si `mypassword` no está permitido, los usuarios pueden intentar algo como `Mypassword1!` o `Myp4$$w0rd` en su lugar.

## Credential stuffing (reutilización de credenciales)

El credential stuffing es un ataque que utiliza listas reales de combinaciones `usuario:contraseña` obtenidas de filtraciones previas.

Este ataque funciona porque muchas personas reutilizan la misma contraseña en distintos servicios. 
