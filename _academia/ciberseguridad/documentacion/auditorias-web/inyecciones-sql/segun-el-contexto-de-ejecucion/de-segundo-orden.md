---
title: Inyección SQL de segundo orden
description: Explicación de las inyecciones SQL de segundo orden.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones-sql/segun-el-contexto-de-ejecucion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL de segundo orden]
---

La inyección de segundo orden se produce cuando  la aplicación procesa la entrada del usuario de una solicitud HTTP y la incorpora a una consulta SQL de forma insegura, almacenandola primero en la aplicación (por ejemplo en un perfil, comentario o campo persistente) y se ejecuta más tarde en otra operación que usa ese dato en una consulta SQL. El ataque no se manifiesta en el momento del almacenamiento, por lo que pasa desapercibido a fuzzers simples; requiere comprender los flujos de lectura/escritura de la aplicación y encontrar el punto donde el dato almacenado se reutiliza en una consulta vulnerable. Su detección es más compleja y su explotación puede tener efectos acumulativos o privilegiados.