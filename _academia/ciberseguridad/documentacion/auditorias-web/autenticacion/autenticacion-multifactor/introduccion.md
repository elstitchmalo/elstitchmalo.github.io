---
title: Introducción
description: Qué son, tipos y cómo funcionan las vulnerabilidades en la autenticación multifactor.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/autenticacion-multifactor/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [autenticacion]
---

La autenticación multifactor (MFA) es un mecanismo de seguridad que busca confirmar la identidad de un usuario usando más de una prueba distinta antes de permitir el acceso a una aplicación web. Su objetivo principal es reducir el riesgo de accesos no autorizados, incluso si una contraseña ha sido robada.

Aunque la autenticación multifactor es más segura que usar solo una contraseña, no es infalible. Si se implementa de forma incorrecta, puede contener vulnerabilidades que un atacante puede aprovechar para eludirla total o parcialmente. Por eso, no basta con “añadir un segundo paso”; es fundamental que los factores usados sean realmente independientes entre sí.

Normalmente se basa en combinar distintos tipos de factores, por ejemplo:

- Algo que sabes: una contraseña o PIN.

- Algo que tienes: un teléfono móvil, una tarjeta física o un generador de códigos.

- Algo que eres: datos biométricos como huellas dactilares (poco usados en aplicaciones web comunes).

En la práctica, la forma más habitual es la autenticación de dos factores (2FA), que suele pedir:

- Una contraseña.

- Un código temporal (por ejemplo, de seis dígitos) enviado o generado en un dispositivo físico que pertenece al usuario.

Esto es más seguro porque, aunque un atacante consiga la contraseña, también necesitaría acceso físico al segundo factor, lo cual es mucho más difícil.

Sin embargo, la seguridad de la 2FA depende completamente de cómo esté implementada. Si el sistema valida mal los factores, permite saltarse pasos o reutiliza el mismo tipo de factor, puede volverse tan vulnerable como un sistema de un solo factor.

Un punto clave es que verificar el mismo tipo de factor dos veces no cuenta como MFA real. Para que la autenticación multifactor sea efectiva, cada factor debe ser independiente.