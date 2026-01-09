---
title: rsa_sign2n
description: Herramienta para pruebas de penetración web de JWT
layout: academia_lesson
parent: /academia/ciberseguridad/herramientas/auditorias-web/jwt/
author: ElStitchMalo
date: 09/01/2026
updated:
tags: [jwt]
---

# rsa_sign2n

Repositorio: https://github.com/silentsignal/rsa_sign2n

## Comandos

### Derivar claves públicas a partir de tokens existentes

~~~
docker run --rm -it portswigger/sig2n <token1> <token2>
~~~

Este comando:

- Usa dos JWT reales (<token1> y <token2>).
- Calcula posibles claves.
- Genera varios JWT falsificados automáticamente.