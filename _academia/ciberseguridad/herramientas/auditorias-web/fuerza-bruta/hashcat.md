---
title: Hashcat
description: Herramienta para pruebas de penetración web de fuerza bruta
layout: academia_lesson
parent: /academia/ciberseguridad/herramientas/auditorias-web/fuerza-bruta/
author: ElStitchMalo
date: 09/01/2026
updated:
tags: [fuerza bruta]
---

# Hashcat

[Instalar Hashcat](https://hashcat.net/wiki/doku.php?id=frequently_asked_questions#how_do_i_install_hashcat)

## Comandos

### Fuerza bruta JWT con diccionario

~~~
hashcat -a 0 -m 16500 <jwt> <wordlist>
~~~