---
title: Ataques JWT
description: Qué son, tipos y cómo funcionan las vulnerabilidades en JWT.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/autenticacion/jwt/
author: ElStitchMalo
date: 11/01/2026
updated:
tags: [JWT]
---

## ¿Qué son los ataques JWT?

Los ataques JWT son técnicas en las que un atacante manipula un token JWT y lo envía al servidor con la intención de engañarlo.
El objetivo más común es hacerse pasar por otro usuario, normalmente uno con más privilegios, para acceder a funciones o datos que no le corresponden.

## ¿Cuál es el impacto de los ataques JWT?

Como los JWT suelen usarse para identificar al usuario y decidir qué puede hacer dentro de una aplicación, si se comprometen, el impacto en la seguridad es muy alto.

## ¿Cómo surgen las vulnerabilidades a los ataques JWT?

Un JWT contiene información clave sobre el usuario, como su identidad o su rol, dentro de su carga útil.
Aunque estos datos pueden ser fácilmente modificados por cualquiera que tenga el token, el servidor debería detectar cualquier cambio comprobando la firma criptográfica del JWT.

Las vulnerabilidades relacionadas con JWT suelen aparecer cuando la aplicación:

- No valida correctamente la firma del token, o
- Confía demasiado en los datos del JWT sin verificarlos adecuadamente.

Si el servidor acepta un JWT cuya firma no es válida, un atacante puede:

- Cambiar su rol (por ejemplo, de usuario normal a administrador).
- Suplantar la identidad de otro usuario ya autenticado.

Incluso cuando la firma se verifica correctamente, la seguridad del sistema depende de que la clave secreta usada para firmar los tokens permanezca protegida.

Si esta clave:

- Se filtra,
- Es débil,
- Puede adivinarse o forzarse,

un atacante podría crear JWT completamente válidos con cualquier contenido, rompiendo por completo el sistema de autenticación y control de acceso.

## Explotación de la verificación de firma JWT defectuosa

Por diseño, los servidores no suelen guardar una copia de los JWT (JSON Web Tokens) que emiten. Esto tiene ventajas, como no tener que almacenar sesiones en el servidor, pero también introduce un problema importante de seguridad:
el servidor no recuerda cómo era el token original, ni siquiera su firma. Por tanto, si el servidor no verifica correctamente la firma, no puede saber si el token ha sido modificado.

Por ejemplo:

~~~
{
    "username": "carlos",
    "isAdmin": false
}
~~~

Si la aplicación identifica la sesión únicamente por el valor `username`, modificarlo permitiría a un atacante hacerse pasar por otro usuario. De igual forma, si el campo `isAdmin` se utiliza para decidir si un usuario tiene privilegios administrativos, cambiarlo de `false` a `true` puede provocar una escalada de privilegios, es decir, obtener permisos que no deberían corresponderle.

Este tipo de errores es común en aplicaciones reales y se explora en los primeros laboratorios prácticos.

### Aceptar firmas arbitrarias

Las bibliotecas que trabajan con JWT suelen ofrecer dos funciones distintas:

- Una función para verificar el token (comprueba la firma y valida que no ha sido alterado).

- Otra función que solo decodifica el contenido del token sin comprobar su autenticidad.

Por ejemplo:

La biblioteca `jsonwebtoken` incluye:

`verify()` → valida la firma y el contenido

`decode()` → solo lee el contenido

Un error frecuente es que los desarrolladores utilicen únicamente `decode()` para procesar tokens entrantes. Esto implica que la firma nunca se verifica, por lo que el servidor acepta cualquier token, incluso uno modificado por un atacante.

### Aceptando tokens sin firma

El encabezado del JWT contiene un parámetro llamado `alg`, que indica qué algoritmo se usó para firmar el token. Por ejemplo:

~~~
{
    "alg": "HS256",
    "typ": "JWT"
}
~~~

El problema es que este encabezado también forma parte del token enviado por el usuario, y el servidor lo lee antes de haber verificado nada. En otras palabras, el servidor confía en información que el atacante puede modificar.

Los JWT permiten un valor especial:

~~~
"alg": "none"
~~~

Esto indica que el token no está firmado. Este tipo de token se considera inseguro, y la mayoría de los servidores modernos intentan rechazarlo.

Sin embargo:

- Algunos filtros se basan solo en comparaciones de texto.

- Estas comprobaciones pueden fallar si el atacante usa técnicas de ofuscación, como:

    - Mezclar mayúsculas y minúsculas (`NoNe`)
    - Usar codificaciones inesperadas

Si el servidor acepta un token con `alg: none`, cualquiera puede crear o modificar tokens válidos sin conocer ninguna clave secreta.

> Incluso cuando un JWT no está firmado, la estructura del token sigue siendo obligatoria. En particular, la parte de la carga útil debe terminar con un punto (`.`) para que el formato sea considerado válido.

## Claves secretas por fuerza bruta

Algunos algoritmos de firma de JWT, como HS256, utilizan una clave secreta compartida.

HS256 combina dos elementos:

- HMAC, un método para firmar datos usando una clave secreta.
- SHA-256, una función que genera un resumen (hash) del contenido.

En términos simples, la clave secreta funciona como una contraseña:
solo el servidor que la conoce debería poder firmar un JWT válido.

Si un atacante logra adivinar o descubrir la clave secreta, puede:

1. Crear un JWT nuevo con cualquier contenido que desee.
2. Firmarlo con esa clave secreta.
3. Enviar el token al servidor.
4. El servidor lo aceptará como legítimo.

Esto permite, por ejemplo:

1. Cambiar el nombre de usuario dentro del token.
2. Activar permisos de administrador.
3. Acceder a funciones restringidas.

En muchas aplicaciones reales, los problemas no vienen del algoritmo, sino de errores humanos. Algunos ejemplos frecuentes son:

- Usar claves por defecto que nunca se cambian.
- Dejar valores de ejemplo o “marcadores de posición”.
- Copiar código de Internet con una clave incluida y olvidar modificarla.

Cuando esto ocurre, los atacantes pueden probar listas de claves conocidas, ya que muchas aplicaciones reutilizan los mismos secretos inseguros.

### Fuerza bruta de claves secretas mediante hashcat

Hashcat es una herramienta que permite probar grandes cantidades de claves de forma automática. En este contexto, se usa para descubrir la clave secreta utilizada para firmar un JWT.

Hashcat:

- Funciona localmente en la máquina del atacante.
- No envía peticiones al servidor.
- Es extremadamente rápido.

Está disponible en Kali Linux, donde suele venir preinstalado.

> Algunas versiones preconfiguradas de Kali en VirtualBox pueden no tener suficiente memoria para ejecutar Hashcat correctamente.

Solo hacen falta dos elementos:

1. Un JWT válido y firmado emitido por el servidor.
2. Una lista de palabras con claves secretas comunes o conocidas.

El comando básico es:

~~~
hashcat -a 0 -m 16500 <jwt> <wordlist>
~~~

Qué hace este comando

- Hashcat toma el encabezado y la carga útil del JWT.
- Los firma una y otra vez usando cada clave de la lista.
- Compara cada firma generada con la firma original del token.
- Si alguna coincide, significa que ha encontrado la clave secreta correcta.

Cuando tiene éxito, muestra el resultado en este formato:

~~~
<jwt>:<identified-secret>
~~~

> Si se ejecuta el comando más de una vez, es necesario usar la opción `--show` para ver los resultados ya obtenidos.

Una vez que el atacante conoce la clave:

- Puede modificar cualquier parte del JWT.
- Volver a firmarlo con una firma válida.
- El servidor no podrá distinguirlo de un token legítimo.

Herramientas como Burp Suite permiten editar y volver a firmar JWT fácilmente cuando se conoce el secreto.

Si el servidor utiliza una clave muy corta o predecible, en algunos casos ni siquiera es necesaria una lista de palabras. Es posible probar combinaciones carácter por carácter, lo que facilita aún más el ataque.

## Inyecciones de parámetros de encabezado JWT

Según la especificación JWS (JSON Web Signature), el único campo obligatorio en el encabezado de un JWT es `alg`, que indica el algoritmo de firma.
Sin embargo, en aplicaciones reales, los encabezados JWT (también llamados encabezados JOSE) suelen incluir parámetros adicionales.

El problema es que estos parámetros viajan dentro del propio token, lo que significa que el usuario puede modificarlos. Si el servidor confía en ellos sin validarlos adecuadamente, pueden convertirse en un punto de ataque.

Los parámetros más interesantes desde el punto de vista de un atacante son:

- `jwk` (JSON Web Key): incluye directamente una clave en formato JSON.
- `jku` (JSON Web Key Set URL): indica una URL desde la que el servidor debe descargar claves.
- `kid` (Key ID): identifica qué clave debe usarse cuando existen varias.

Todos estos parámetros le dicen al servidor qué clave usar para verificar la firma. Si el servidor los acepta sin restricciones, un atacante puede hacer que se valide un JWT firmado con su propia clave, en lugar de la clave legítima del servidor.

### Inyección de JWT autofirmados a través del parámetro jwk

Una JWK (JSON Web Key) es una forma estándar de representar una clave criptográfica como un objeto JSON.

El parámetro `jwk` permite incrustar directamente una clave pública dentro del JWT. Por ejemplo:

~~~
{
    "kid": "ed2Nf8sb-sD6ng0-scs5390g-fFD8sfxG",
    "typ": "JWT",
    "alg": "RS256",
    "jwk": {
        "kty": "RSA",
        "e": "AQAB",
        "kid": "ed2Nf8sb-sD6ng0-scs5390g-fFD8sfxG",
        "n": "yy1wpYmffgXBxhAUJzHHocCuJolwDqql75ZWuCQ_cb33K2vh9m"
    }
}
~~~

**Claves públicas y privadas**

- Clave privada: se usa para firmar el JWT (debe mantenerse secreta).
- Clave pública: se usa para verificar la firma (puede compartirse).

En sistemas seguros, el servidor solo confía en claves públicas previamente autorizadas.

Pero algunos servidores mal configurados aceptan cualquier clave incluida en el `jwk` del token.

**Cómo se explota esta vulnerabilidad**

1. El atacante genera su propio par de claves RSA.
2. Firma un JWT modificado con su clave privada.
3. Inserta la clave pública correspondiente en el parámetro jwk.
4. El servidor usa esa clave para verificar la firma… y acepta el token.

### Inyección de JWT autofirmados a través del parámetro jku

En lugar de incluir la clave directamente, algunos servidores permiten indicar una URL mediante el parámetro `jku`. Desde esa URL, el servidor descarga un conjunto de claves `JWK`.

Un conjunto JWK es un objeto JSON que contiene varias claves públicas:

~~~
{
    "keys": [
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "75d0ef47-af89-47a9-9061-7c02a610d5ab",
            "n": "o-yy1wpYmffgXBxhAUJzHHocCuJolwDqql75ZWuCQ_cb33K2vh9mk6GPM9gNN4Y_qTVX67WhsN3JvaFYw-fhvsWQ"
        },
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "d8fDFo-fS9-faS14a9-ASf99sa-7c1Ad5abA",
            "n": "fc3f-yy1wpYmffgXBxhAUJzHql79gNNQ_cb33HocCuJolwDqmk6GPM4Y_qTVX67WhsN3JvaFYw-dfg6DH-asAScw"
        }
    ]
}
~~~

Estos conjuntos suelen estar disponibles públicamente en rutas como:

~~~
/.well-known/jwks.json
~~~

### Inyección de JWT autofirmados a través del parámetro kid

Un servidor no suele usar una sola clave criptográfica. Puede tener varias claves distintas para firmar o verificar diferentes tipos de datos, incluidos los JWT (JSON Web Tokens). Para saber qué clave debe usar, el encabezado del JWT puede incluir el parámetro `kid` (Key ID o identificador de clave).

En términos simples, `kid` es una etiqueta que le dice al servidor:

- “usa esta clave concreta para verificar la firma de este token”.

#### Cómo se usa normalmente el parámetro

Las claves de verificación suelen almacenarse en un conjunto JWK, que es una colección de claves representadas en formato JSON.
En un escenario correcto:

1. El servidor recibe el JWT.
2. Lee el valor de `kid`.
3. Busca una clave con ese mismo identificador dentro de su conjunto JWK.
4. Usa esa clave para verificar la firma.

#### El problema: `kid` no tiene un formato definido

La especificación JWS no impone ninguna estructura al parámetro `kid`.
Es simplemente una cadena de texto arbitraria elegida por el desarrollador.

Por este motivo, algunos sistemas usan kid para:

- Apuntar a un registro concreto en una base de datos.
- Indicar el nombre o la ruta de un archivo en el sistema.

Si esta cadena no se valida correctamente, puede abrir la puerta a ataques.

#### Uso malicioso de `kid` mediante navegación de directorios

Si el servidor utiliza `kid` como una ruta de archivo, y es vulnerable a navegación de directorios (path traversal), un atacante puede forzar al servidor a leer archivos arbitrarios del sistema como si fueran claves criptográficas.

Ejemplo de encabezado JWT malicioso:

~~~
{
    "kid": "../../path/to/file",
    "typ": "JWT",
    "alg": "HS256",
    "k": "asGsADas3421-dfh9DGN-AFDFDbasfd8-anfjkvc"
}
~~~

En este caso, el atacante intenta que el servidor use un archivo del sistema como clave de verificación.

#### Por qué esto es especialmente peligroso con algoritmos simétricos

Con algoritmos simétricos (como HS256):

- La misma clave se usa para firmar y para verificar el JWT.
- Si el atacante sabe qué archivo se está usando como clave, puede firmar el token con ese mismo contenido.

***Ejemplo práctico: `/dev/null`***

En la mayoría de sistemas Linux existe el archivo:

~~~
/dev/null
~~~

Características importantes:

- Es un archivo vacío.
- Leerlo devuelve una cadena vacía.

Si el atacante consigue que el servidor use /dev/null como clave:

1. Firma el JWT usando una clave vacía.
2. El servidor verifica la firma usando el mismo archivo.
3. La firma resulta válida.

Esto permite crear JWT completamente controlados por el atacante.

#### Riesgo adicional: inyección SQL

Si el servidor usa el valor de `kid` para construir consultas a una base de datos, y no lo filtra correctamente, este parámetro también puede ser un vector de inyección SQL.

Esto significa que un atacante podría:

- Manipular consultas.
- Acceder a claves no autorizadas.
- Alterar el comportamiento del sistema de verificación.

### Otros parámetros interesantes del encabezado JWT

Además de los parámetros más conocidos del encabezado JWT, existen otros campos opcionales que, si el servidor los procesa sin las debidas precauciones, pueden resultar interesantes para un atacante.

Estos parámetros no suelen aparecer en implementaciones normales, pero algunas bibliotecas los aceptan igualmente, lo que puede abrir nuevas superficies de ataque.

#### Parámetro `cty` (Content Type o tipo de contenido)

El parámetro `cty` se utiliza para indicar qué tipo de contenido contiene la carga útil (payload) del JWT, de forma similar a cómo un encabezado HTTP indica el tipo de datos que transporta una respuesta.

Normalmente:

- Este parámetro no se incluye en los JWT.
- Muchas aplicaciones no lo necesitan.

Sin embargo, algunas bibliotecas que procesan JWT lo interpretan automáticamente si está presente.

Si un atacante ya ha conseguido evitar la verificación de la firma del JWT, puede aprovechar `cty` para forzar a la aplicación a interpretar el contenido como otro formato, por ejemplo:

- text/xml
- application/x-java-serialized-object

Esto puede provocar que el servidor intente procesar la carga útil como:

- **XML**, abriendo la puerta a ataques XXE (XML External Entity).
- **Objetos serializados**, lo que puede llevar a ataques de deserialización insegura.

El problema no es el parámetro en sí, sino que el servidor confíe en él sin verificar la firma del token.

#### Parámetro `x5c` (cadena de certificados X.509)

El parámetro `x5c` se utiliza para incluir:

- Un certificado X.509, o
- Una cadena de certificados asociada a la clave que firmó el JWT.

Los certificados X.509 se usan habitualmente en sistemas de cifrado para vincular una clave pública con una identidad.

Si el servidor acepta este parámetro sin restricciones:

- Un atacante puede inyectar certificados autofirmados.
- El servidor puede usar esos certificados para validar la firma del JWT, de forma similar a los ataques basados en `jwk`.

Además, el formato X.509 es complejo y tiene múltiples extensiones.
Errores al procesar estos certificados pueden introducir vulnerabilidades adicionales durante el análisis.

Algunos fallos reales relacionados con este tipo de procesamiento han sido documentados en:

- CVE-2017-2800
- CVE-2018-2633

## Confusión del algoritmo JWT

Los ataques de confusión de algoritmos (también llamados confusión de claves) ocurren cuando un atacante consigue que el servidor verifique un JWT usando un algoritmo distinto del que los desarrolladores esperaban.

Si este escenario no se gestiona correctamente, el resultado es crítico:

- el atacante puede crear JWT válidos con cualquier contenido, sin conocer la clave secreta real del servidor.

## Algoritmos simétricos vs. asimétricos

Los JWT pueden firmarse usando distintos algoritmos criptográficos, que se dividen principalmente en dos tipos.

### Algoritmos simétricos (ejemplo: HS256)

Con algoritmos como HS256:

- Se utiliza una sola clave.
- La misma clave sirve para:
    - Firmar el token.
    - Verificar la firma.

Esta clave debe mantenerse en secreto, igual que una contraseña.
Si un atacante la conoce, puede generar JWT completamente válidos.

### Algoritmos asimétricos (ejemplo: RS256)

Con algoritmos como RS256:

- Se usan dos claves relacionadas entre sí:
    - Clave privada: solo el servidor la conoce y la usa para firmar el JWT.
    - Clave pública: se usa para verificar la firma y puede compartirse.

La seguridad se basa en que la clave privada nunca se expone, mientras que la clave pública puede ser conocida por cualquiera.

## ¿Cómo surgen las vulnerabilidades de confusión de algoritmos?

El problema no suele estar en el algoritmo, sino en cómo se implementa la verificación en las bibliotecas JWT.

Muchas bibliotecas ofrecen una única función genérica para verificar JWT, independientemente del algoritmo.

Esta función suele decidir qué tipo de verificación realizar basándose en el valor `alg` incluido en el encabezado del token, que puede ser modificado por el usuario.

Ejemplo simplificado de lógica interna:

~~~
function verify(token, secretOrPublicKey){
    algorithm = token.getAlgHeader();
    if(algorithm == "RS256"){
        // Usa la clave como clave pública RSA
    } else if (algorithm == "HS256"){
        // Usa la clave como secreto HMAC
    }
}
~~~

### El error típico del desarrollador

Muchos desarrolladores asumen que su aplicación solo recibirá JWT firmados con un algoritmo asimétrico como RS256. Por eso, siempre pasan la clave pública del servidor al método de verificación:

~~~
publicKey = <clave-publica-del-servidor>;
token = request.getCookie("session");
verify(token, publicKey);
~~~

Este enfoque parece correcto… pero introduce una vulnerabilidad grave.

### Cómo se explota el ataque

1. El atacante modifica el JWT y cambia el encabezado a:

    ~~~
    "alg": "HS256"
    ~~~
2. Firma el token usando HS256.
3. Usa la clave pública del servidor como clave secreta HMAC.
4. El servidor:
    - Lee `alg` del token.
    - Decide usar HS256.
    - Trata la clave pública como si fuera un secreto.
    - Verifica la firma correctamente.

El servidor acepta el token como válido, aunque ha sido creado por el atacante.

### Detalle importante sobre el formato de la clave

Para que el ataque funcione:

- La clave pública usada por el atacante debe ser idéntica a la que usa el servidor.
- Esto incluye:
    - El mismo formato (por ejemplo, PEM X.509).
    - Los mismos caracteres, incluidos saltos de línea y caracteres no imprimibles.

En la práctica, puede ser necesario probar distintos formatos hasta que la firma sea aceptada.

## Realizar un ataque de confusión de algoritmos

Un ataque de confusión de algoritmos aprovecha una mala implementación de la verificación de JWT para engañar al servidor y hacerle aceptar un token falso como válido.

A alto nivel, este ataque sigue siempre la misma lógica:

1. Obtener la clave pública del servidor.
2. Convertir esa clave a un formato que el servidor acepte.
3. Crear un JWT modificado con `alg: HS256`.
4. Firmar el token usando HS256, utilizando la clave pública como si fuera un secreto.

A continuación, se explica cada paso con más detalle y cómo puede realizarse usando Burp Suite.

### Paso 1 – Obtener la clave pública del servidor

Muchos servidores publican sus claves públicas para que otros sistemas puedan verificar los JWT que emiten.

Estas claves suelen exponerse como JWK (JSON Web Key) en endpoints estándar, por ejemplo:

- `/jwks.json`
- `/.well-known/jwks.json`

Estas claves suelen agruparse en un conjunto JWK, que es simplemente un objeto JSON que contiene varias claves:

~~~
{
    "keys": [
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "75d0ef47-af89-47a9-9061-7c02a610d5ab",
            "n": "o-yy1wpYmffgXBxhAUJzHHocCuJolwDqql75ZWuCQ_cb33K2vh9mk6GPM9gNN4Y_qTVX67WhsN3JvaFYw-fhvsWQ"
        },
        {
            "kty": "RSA",
            "e": "AQAB",
            "kid": "d8fDFo-fS9-faS14a9-ASf99sa-7c1Ad5abA",
            "n": "fc3f-yy1wpYmffgXBxhAUJzHql79gNNQ_cb33HocCuJolwDqmk6GPM4Y_qTVX67WhsN3JvaFYw-dfg6DH-asAScw"
        }
    ]
}
~~~

Incluso si el servidor no expone la clave públicamente, en algunos casos es posible extraerla a partir de JWT ya emitidos, ya que contienen información relacionada con la clave usada para firmarlos.

### Paso 2 – Convertir la clave pública a un formato adecuado

Aunque el servidor publique su clave pública como JWK, internamente puede estar usando otro formato, por ejemplo X.509 PEM.

Para que el ataque funcione:

- La clave usada para firmar el JWT debe ser idéntica a la que usa el servidor.

- No basta con que represente la misma clave:  
cada byte debe coincidir, incluidos saltos de línea y otros caracteres no visibles.

**Conversión usando Burp Suite (JWT Editor)**

Con la extensión JWT Editor instalada en Burp:

1. Vaya a la pestaña Claves del editor JWT.
2. Haga clic en Nueva clave RSA.
3. Pegue la clave en formato JWK obtenida antes.
4. Seleccione el formato PEM y copie la clave generada.
5. Vaya a la pestaña Decoder y codifique el PEM en Base64.
6. Regrese a Claves del editor JWT y cree una nueva clave simétrica.
7. Reemplace el valor del parámetro `k` con la clave PEM codificada en Base64.
8. Guarde la clave.

De este modo, la clave pública se transforma en un “secreto” compatible con HS256.

### Paso 3 – Modificar el JWT

Ahora puede modificar el contenido del JWT (la carga útil) como desee, por ejemplo:

- Cambiar el usuario.
- Elevar privilegios.

Es fundamental que el encabezado del token indique:

~~~
"alg": "HS256"
~~~

Esto fuerza al servidor a verificar el token usando un algoritmo simétrico.

### Paso 4: Firme el JWT usando la clave pública

Finalmente:

- Firme el JWT con HS256.
- Use la clave pública RSA (convertida previamente) como clave secreta.

Si el servidor es vulnerable:

- Usará esa misma clave pública para verificar la firma.
- Considerará el JWT como válido.
- Aceptará el contenido modificado por el atacante.

## Derivación de claves públicas a partir de tokens existentes

Cuando una aplicación web usa JWT con algoritmos de firma asimétricos (por ejemplo, RSA), el servidor debería verificar los tokens usando una clave pública. Sin embargo, incluso si esa clave pública no está disponible, todavía es posible comprobar si la aplicación es vulnerable a un ataque de confusión de algoritmos.

Este tipo de ataque consiste en engañar al servidor para que use el método de validación incorrecto, permitiendo al atacante crear tokens falsificados que el servidor acepta como válidos.

En algunos escenarios, un atacante puede obtener dos JWT legítimos emitidos por el servidor. Aunque no conozca la clave pública, puede intentar derivar información criptográfica a partir de esos tokens.

Herramientas especializadas, como `jwt_forgery.py` ([disponible en GitHub](https://github.com/silentsignal/rsa_sign2n)), automatizan este proceso.  
Estas herramientas analizan los JWT proporcionados y calculan varios valores posibles de un parámetro llamado n, que forma parte de la clave RSA usada por el servidor.

No es necesario entender los detalles matemáticos de `n`. Lo importante es saber que:

- Solo uno de esos valores coincide con la clave real del servidor.
- Para cada valor posible, la herramienta genera:
    - Una clave pública falsa en formato PEM (codificada en Base64).
    - Un JWT falsificado, firmado usando esa clave.

Para saber cuál es la clave correcta:
    - Se envía cada JWT falsificado al servidor.
    - El servidor solo aceptará uno, el que esté firmado con la clave que coincide con la suya.

Una vez identificada la clave válida, el atacante puede usarla para realizar un ataque de confusión de algoritmos, manipulando JWT de forma fiable.

Una versión simplificada de esta técnica puede ejecutarse con un solo comando usando Docker:

~~~
docker run --rm -it portswigger/sig2n <token1> <token2>
~~~

Este comando:

- Usa dos JWT reales (<token1> y <token2>).
- Calcula posibles claves.
- Genera varios JWT falsificados automáticamente.

Luego, con una herramienta como Burp Repeater, se prueban uno a uno contra el servidor hasta encontrar el que funciona.

> Es necesario tener instalada la CLI de Docker.
La primera vez que se ejecuta el comando, Docker descargará la imagen necesaria, lo cual puede tardar unos minutos.

## Cómo prevenir ataques JWT

Prevenir ataques JWT significa asegurarse de que los tokens usados para identificar usuarios no puedan ser manipulados, reutilizados indebidamente ni aceptados sin las comprobaciones correctas. Dado que los JWT suelen controlar quién puede acceder a qué dentro de una aplicación web, un error en su manejo puede comprometer toda la seguridad del sistema.

La prevención se basa principalmente en usar bien las bibliotecas, verificar correctamente las firmas y controlar estrictamente qué datos se aceptan dentro del token.

Para reducir el riesgo de vulnerabilidades relacionadas con JWT, se recomiendan las siguientes medidas clave:

**Uso correcto de bibliotecas JWT**

- Utilice bibliotecas actualizadas para gestionar JWT.
- Asegúrese de que los desarrolladores entienden cómo funcionan los JWT y sus implicaciones de seguridad.
- Aunque las bibliotecas modernas ayudan a evitar errores, las especificaciones JWT son muy flexibles, lo que permite configuraciones inseguras si no se usan con cuidado.

**Verificación estricta de la firma**

- El servidor debe verificar siempre la firma de todos los JWT que recibe.
- No debe aceptar tokens firmados con algoritmos inesperados o no permitidos, ya que esto puede abrir la puerta a ataques como la confusión de algoritmos.

**Control del encabezado `jku`**

- El parámetro `jku` puede indicar desde dónde obtener una clave pública.
- Debe aplicarse una lista blanca estricta de hosts permitidos, evitando que el servidor cargue claves desde ubicaciones controladas por un atacante.

**Validación del parámetro `kid`**

- El parámetro `kid` identifica qué clave usar para verificar el token.
- Si se maneja de forma insegura, puede provocar:
    - Travesía de rutas (acceder a archivos no previstos).
    - Inyección SQL.
- Por ello, debe validarse cuidadosamente y nunca usarse directamente sin controles.

### Prácticas recomendadas adicionales

Aunque no evitan vulnerabilidades por sí solas, estas prácticas mejoran la seguridad general:

- Establecer siempre una fecha de expiración para los tokens.
- Evitar enviar JWT en URLs, ya que pueden filtrarse fácilmente.
- Incluir el campo `aud` (audiencia) para indicar para qué aplicación es válido el token.
- Permitir que el servidor revoque tokens, por ejemplo al cerrar sesión.

Estas medidas ayudan a limitar el impacto de un token comprometido y refuerzan el control sobre su uso.