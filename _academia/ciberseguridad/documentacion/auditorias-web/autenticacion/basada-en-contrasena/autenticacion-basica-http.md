---
title: Autenticación básica HTTP
description: Autenticación básica HTTP
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/basada-en-contrasena/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [autenticacion]
---

La autenticación básica por HTTP es un método antiguo para verificar la identidad de un usuario en un sitio web. Aunque hoy existen sistemas más seguros, todavía se encuentra en algunas aplicaciones debido a que es simple de implementar y funciona sin configuraciones complejas.

Sin embargo, esta simplicidad tiene un coste importante: no ofrece una protección adecuada frente a ataques modernos, lo que la convierte en una opción insegura para proteger información sensible.

En la autenticación básica HTTP, el proceso funciona así:

1. El usuario introduce su nombre de usuario y contraseña.

2. El navegador los une en un solo texto con el formato `usuario:contraseña`.

3. Ese texto se codifica en **Base64**, que es solo una forma de representar datos en texto, no un cifrado.

4. El navegador guarda ese valor y lo envía automáticamente en cada solicitud HTTP al servidor mediante el encabezado:

~~~
Authorization: Basic base64(usuario:contraseña)
~~~

## Problemas de seguridad principales

1. **Las credenciales se envían repetidamente**  
En cada petición al servidor se envían el usuario y la contraseña. Si un atacante intercepta una sola solicitud, obtiene las credenciales completas.

2. **Riesgo de ataques de intermediario (Man-in-the-Middle)**
Si el sitio no usa correctamente HTTPS con mecanismos como HSTS (una política que obliga al navegador a usar conexiones cifradas), un atacante que controle la red puede capturar fácilmente las credenciales.

3. **Base64 no es protección real**  
Base64 no cifra la información; cualquiera puede decodificarla y ver el usuario y la contraseña en texto claro.

4. **Sin protección contra fuerza bruta**  
Como el token siempre contiene los mismos datos estáticos, un atacante puede probar combinaciones de usuario y contraseña sin encontrar bloqueos o limitaciones adecuadas.

5. **Vulnerable a ataques de sesión, especialmente CSRF**  
CSRF (Cross-Site Request Forgery) es un ataque en el que el navegador del usuario realiza acciones sin su consentimiento. La autenticación básica HTTP no incluye mecanismos propios para prevenir este tipo de ataques.