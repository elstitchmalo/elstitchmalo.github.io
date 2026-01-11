---
title: Fallos comunes en las defensas contra fuerza bruta
description: Fallos en las defensas contra fuerza bruta.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/basada-en-contrasena/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [fuerza bruta]
---

Para mitigar estos ataques, los sistemas suelen implementar controles automáticos. Sin embargo, estos mecanismos a menudo presentan errores lógicos que permiten su evasión.

## Limitación de tasa de peticiones defectuosa (Rate Limiting)

La limitación de la tasa de peticiones bloquea o ralentiza a un cliente cuando envía demasiadas solicitudes en poco tiempo, normalmente basándose en la dirección IP.

Un fallo común de esta medida de seguridad ocurre cuando:

- Cuenta los intentos fallidos por dirección IP.

- Reinicia el contador si desde esa misma IP se produce un inicio de sesión correcto.

Esto permite que un atacante:

- Intercale inicios de sesión válidos (por ejemplo, usando su propia cuenta).

- Evite alcanzar el límite de bloqueos.

- Continúe probando contraseñas indefinidamente.

La defensa existe, pero no cumple su objetivo real.

El desbloqueo suele ocurrir:

- Automáticamente tras un tiempo.

- Manualmente por un administrador.

- Tras resolver un CAPTCHA (prueba para verificar que eres humano).

Esta técnica es preferida en algunos casos porque:

- Reduce la enumeración de usuarios.

- Disminuye el riesgo de ataques de denegación de servicio.

Sin embargo, no es infalible, ya que un atacante puede:

- Cambiar o manipular su dirección IP.

- Distribuir los intentos entre varias IP.

- Encontrar formas de probar múltiples contraseñas en una sola solicitud HTTP.

## Bloqueo de cuentas

El bloqueo de cuentas consiste en desactivar temporalmente un usuario tras cierto número de intentos fallidos. Esta medida:

- Puede proteger una cuenta concreta.

- Pero no evita ataques a gran escala contra muchas cuentas diferentes.

Además, los mensajes del servidor que indican que `la cuenta está bloqueada` pueden dar pistas a un atacante sobre qué nombres de usuario son válidos, facilitando la enumeración de usuarios (descubrir qué cuentas existen).

Un atacante puede evadir este mecanismo de forma sencilla:

1. Crear una lista de nombres de usuario probables (obtenidos por enumeración o listas comunes).

2. Elegir pocas contraseñas muy habituales (menos o igual al límite permitido).

3. Probar cada contraseña con cada usuario.

De esta forma:

- Ninguna cuenta supera el límite de intentos.

- Basta con que una sola persona use una de esas contraseñas para que una cuenta sea comprometida.

Además, este tipo de bloqueos, tampoco protege contra el robo de credenciales (Credential Stuffing), porque:

- Cada usuario se prueba una sola vez.

- No se activan los límites de intentos.

- Un solo ataque automatizado puede comprometer varias cuentas reales.