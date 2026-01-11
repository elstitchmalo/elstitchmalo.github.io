---
title: Vulnerabilidades en otros mecanismos
description: Otras posibles vulnerabilidades que podemos encontrar en la autenticación.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/otros-mecanismos/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [autenticacion]
---

## Mantener a los usuarios conectados

Muchos sitios web ofrecen la opción de mantener la sesión iniciada, incluso después de cerrar el navegador. Normalmente aparece como una casilla con textos como “Recordarme” o “Mantener la sesión iniciada”. Su objetivo es evitar que el usuario tenga que introducir su usuario y contraseña cada vez que visita el sitio.

### ¿Cómo funciona técnicamente esta opción?

Para implementar esta funcionalidad, el servidor suele generar un token de “recordarme”.  
Un token es simplemente un valor largo y aparentemente aleatorio que identifica al usuario. Este token se guarda en una cookie persistente, es decir, un pequeño archivo almacenado en el navegador que no se elimina al cerrar la ventana.

Cuando el usuario vuelve al sitio, el navegador envía esa cookie al servidor. Si el token es válido, el servidor considera al usuario autenticado sin pedirle la contraseña.

> Punto clave: cualquiera que posea esa cookie puede acceder a la cuenta. Por eso, el token debe ser extremadamente difícil de adivinar o reproducir.

### Errores comunes en la generación de cookies “recordarme”

Algunos sitios web generan estos tokens de forma insegura, por ejemplo:

- Combinando datos predecibles, como el nombre de usuario y una fecha.

- Incluyendo información sensible, como la contraseña (o una versión de ella).

Esto es peligroso porque un atacante puede crear su propia cuenta, observar su propia cookie y deducir cómo se genera. Una vez que entiende la “fórmula”, puede intentar crear cookies válidas para otros usuarios y acceder a sus cuentas sin conocer sus contraseñas.

### ¿Cifrar la cookie es suficiente?

Algunos desarrolladores asumen que cifrar la cookie la hace segura automáticamente, pero esto no siempre es cierto.

- Base64 no es cifrado: es solo una codificación reversible. Cualquiera puede decodificarla fácilmente.

- Usar una función hash (una función que transforma datos en un valor fijo y aparentemente aleatorio) mejora la seguridad, pero no es infalible por sí sola.

- Si el algoritmo hash es conocido y no se utiliza una sal, un atacante puede probar miles de valores hasta encontrar uno que produzca el mismo resultado.

Una sal es un valor aleatorio adicional que se añade antes de aplicar el hash. Su función es evitar que el mismo dato produzca siempre el mismo resultado y dificultar los ataques por fuerza bruta.

Sin una sal adecuada, un atacante puede usar listas de contraseñas comunes (o sus hashes) para generar cookies válidas, incluso evitando los límites de intentos de inicio de sesión tradicionales.

### Forzar cookies de “sesión iniciada”

Incluso si el atacante no puede crear una cuenta propia, aún puede explotar este tipo de fallos. Por ejemplo:

- Mediante XSS (Cross-Site Scripting), una vulnerabilidad que permite ejecutar código malicioso en el navegador de otro usuario, el atacante puede robar su cookie de “recordarme”.

- Analizando esa cookie, puede deducir cómo se construye.

Si el sitio utiliza un framework de código abierto, es posible que el método de generación de la cookie esté documentado públicamente, lo que facilita aún más el ataque.

### Riesgo extremo: recuperar contraseñas desde cookies

En casos especialmente graves, una cookie puede contener información que permita obtener la contraseña real del usuario, incluso si está en forma de hash.
Existen bases de datos públicas con hashes de contraseñas conocidas. Si la contraseña del usuario aparece en una de ellas, el atacante puede identificarla fácilmente, incluso usando un buscador.

Esto demuestra por qué:

- Nunca deben incluirse contraseñas en cookies.

- El uso de sal y algoritmos criptográficos adecuados es esencial.

- Las cookies de “recordarme” deben ser tokens aleatorios, sin relación directa con datos del usuario.

## Restablecimiento de contraseñas de usuario

En la práctica, es normal que los usuarios olviden su contraseña, por lo que los sitios web suelen ofrecer una función para restablecerla. El problema es que, en este punto, el sistema ya no puede usar el método habitual de autenticación (usuario y contraseña), porque precisamente la contraseña no está disponible.
Por este motivo, el restablecimiento de contraseñas es una funcionalidad especialmente sensible y, si se diseña mal, puede permitir que un atacante tome el control de cuentas ajenas.

Existen varias formas comunes de implementar esta función, cada una con distintos riesgos de seguridad.

### Envío de contraseñas por correo electrónico

Enviar al usuario su contraseña actual nunca debería ser posible si el sistema está bien diseñado. Esto implicaría que las contraseñas se almacenan de forma insegura.
Algunos sitios, en lugar de eso, generan una nueva contraseña y la envían por correo electrónico.

Este enfoque también es problemático. El correo electrónico no es un canal seguro: los mensajes suelen permanecer almacenados en la bandeja de entrada y muchos usuarios sincronizan su correo entre varios dispositivos. Si alguien accede al correo, puede obtener la contraseña sin dificultad.

La seguridad de este método depende de que la contraseña enviada:

- caduque rápidamente.

- obligue al usuario a cambiarla en el primer inicio de sesión.

Si esto no se cumple, el sistema queda expuesto a ataques de interceptación o acceso no autorizado al correo.

### Restablecimiento de contraseñas mediante una URL

Un método más seguro consiste en enviar al usuario un enlace único que lo lleva a una página donde puede establecer una nueva contraseña.

Las implementaciones inseguras usan URLs con parámetros predecibles, por ejemplo:

~~~
http://vulnerable-website.com/reset-password?user=victim-user
~~~

Aquí, el parámetro `user` identifica directamente la cuenta. Un atacante podría modificar ese valor y acceder a la página de restablecimiento de cualquier usuario, cambiando su contraseña sin autorización.

#### Uso de tokens seguros en la URL

Una implementación correcta utiliza un token, que es un valor largo, aleatorio y difícil de adivinar. La URL se construye a partir de ese token, no del nombre de usuario:

~~~
http://vulnerable-website.com/reset-password?token=a0ba0d1cb3b63d13822572fcff1a241895d893f659164d4cc550b421ebdd48a8
~~~

Cuando el usuario abre el enlace, el servidor comprueba:

1. Si el token existe.

2. A qué usuario está asociado.

3. Si aún no ha expirado.

Este token debe:

- Expirar tras un corto periodo de tiempo.

- Eliminarse inmediatamente después de usarlo.

La URL, además, no debería revelar ninguna información sobre la cuenta afectada.

#### Validación incorrecta del token en la URL

Un error común es no validar el token al enviar el formulario final de restablecimiento.
En estos casos, un atacante puede:

- Acceder a su propio formulario de restablecimiento.

- Eliminar o modificar el token.

- Usar esa página para cambiar la contraseña de otro usuario.

Esto suele ocurrir por una lógica de validación incompleta en el servidor.

#### Envenenamiento por restablecimiento de contraseña

El envenenamiento del restablecimiento de contraseña es una técnica de ataque en la que un atacante engaña a un sitio web vulnerable para que genere un enlace de restablecimiento de contraseña que apunta a un servidor controlado por el propio atacante, en lugar del sitio legítimo.

El objetivo de este ataque es robar el token de restablecimiento de contraseña.
Un token es un valor secreto y temporal que actúa como una “llave” para autorizar el cambio de contraseña. Si un atacante obtiene ese token, puede cambiar la contraseña de la víctima y tomar control de su cuenta.

##### ¿Cómo funciona normalmente un restablecimiento de contraseña?

La mayoría de los sitios web con inicio de sesión ofrecen una opción para recuperar la contraseña cuando el usuario la olvida. Uno de los métodos más comunes y seguros funciona así:

1. **Solicitud del usuario**  
El usuario introduce su nombre de usuario o correo electrónico en un formulario de “Olvidé mi contraseña”.

2. **Generación del token**  
El servidor comprueba que la cuenta existe y genera un token único, temporal y difícil de adivinar (esto se llama alta entropía).  
Este token se guarda en el servidor y se asocia a la cuenta del usuario.

3. **Envío del enlace por correo**  
El sitio envía un correo electrónico con un enlace que incluye el token como parte de la URL (dirección web), por ejemplo:

~~~
https://normal-website.com/reset?token=0a1b2c3d4e5f6g7h8i9j
~~~

4. **Cambio de contraseña**
Cuando el usuario hace clic en el enlace:
    - El servidor verifica que el token sea válido.
    - Identifica qué cuenta se va a restablecer.
    - Permite al usuario establecer una nueva contraseña.
    - El token se invalida y ya no puede volver a usarse.

Este sistema es relativamente seguro porque solo el usuario debería tener acceso al correo electrónico donde llega el token. El ataque de envenenamiento rompe precisamente esta suposición.

##### ¿En qué consiste el envenenamiento del restablecimiento de contraseña?

El ataque es posible cuando el sitio web construye el enlace de restablecimiento usando datos que el usuario puede manipular, como el encabezado HTTP `Host`.

> El encabezado Host indica al servidor qué dominio está solicitando el cliente (por ejemplo, `example.com`). Si el servidor confía ciegamente en este valor, un atacante puede modificarlo.

##### Paso a paso del ataque

Supongamos que el atacante controla el dominio `evil-user.net`.

1. **Solicitud manipulada**  
El atacante solicita un restablecimiento de contraseña para la víctima (usando su correo o nombre de usuario).  
Antes de que la solicitud llegue al servidor, modifica el encabezado `Host` para que apunte a su propio dominio.

2. **Correo legítimo, enlace malicioso**  
El sitio web envía un correo auténtico a la víctima.  
El mensaje parece legítimo y contiene un token válido, pero el enlace apunta al dominio del atacante:

    ~~~
    https://evil-user.net/reset?token=0a1b2c3d4e5f6g7h8i9j
    ~~~
 
3. **Robo del token**    
Si la víctima hace clic en el enlace (o si algún sistema automático lo analiza, como un escáner de seguridad), el navegador enviará el token al servidor del atacante.

4. **Compromiso de la cuenta**  
Con el token robado, el atacante accede al sitio web real y lo utiliza para restablecer la contraseña de la víctima.  
A partir de ese momento, puede iniciar sesión como ese usuario.

En ataques reales, el atacante puede aumentar la probabilidad de éxito usando técnicas de ingeniería social, como enviar alertas falsas de seguridad para inducir a la víctima a hacer clic rápidamente.

##### Otros riesgos relacionados

Incluso cuando no se puede modificar directamente el enlace de restablecimiento, un mal uso del encabezado Host puede permitir inyección de HTML en correos electrónicos.

- Los clientes de correo normalmente no ejecutan JavaScript, lo que limita algunos ataques.

- Aun así, existen técnicas como el marcado colgante (dangling markup), que permiten manipular el contenido del correo y filtrar información sensible.

## Cambiar las contraseñas de los usuarios

En la mayoría de los sitios web, cambiar una contraseña es un proceso sencillo que normalmente sigue estos pasos:

1. El usuario introduce su contraseña actual.

2. Introduce la nueva contraseña.

3. Repite la nueva contraseña para evitar errores de escritura.

El servidor verifica que la contraseña actual sea correcta y, si lo es, guarda la nueva contraseña.

Este proceso es muy similar al de una página de inicio de sesión, ya que en ambos casos el sistema comprueba que el nombre de usuario y la contraseña coinciden.
Por esta razón, las páginas de cambio de contraseña pueden sufrir los mismos tipos de ataques que una página de login, como intentos repetidos para adivinar contraseñas.

### Riesgos de seguridad en el cambio de contraseñas

La función de cambio de contraseña puede volverse especialmente peligrosa si no está bien protegida.

#### Acceso sin autenticación

Un problema grave ocurre cuando el sistema permite acceder a la función de cambio de contraseña sin que el usuario haya iniciado sesión previamente.  
En este caso, el servidor no tiene una forma fiable de saber quién está solicitando el cambio.

#### Uso inseguro del nombre de usuario

Algunas aplicaciones incluyen el nombre de usuario en un campo oculto dentro del formulario. Si el servidor confía en ese valor sin verificarlo correctamente:

- Un atacante puede modificar el nombre de usuario antes de enviar la solicitud.
- Esto le permitiría intentar cambiar la contraseña de cualquier cuenta, no solo la suya.