---
title: Consultas apiladas
description: Explicación de las consultas apiladas.
layout: academia_lesson
parent: /academia/ciberseguridad/documentacion/auditorias-web/inyecciones/inyecciones-sql/segun-el-contexto-de-ejecucion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [consultas apiladas]
---

Las consultas apiladas ocurren cuando la aplicación acepta que en una misma petición SQL se envíen varias sentencias separadas por `;`. Si la entrada de usuario no está controlada y el driver/stack permite múltiples statements, un atacante puede añadir sentencias adicionales (por ejemplo `; DROP TABLE ...;`) que se ejecutarán tras la consulta original. Esto permite efectos secundarios (modificar datos, crear archivos, ejecutar procedimientos) y por tanto suele tener un impacto muy alto. Requiere que el driver/cliente acepte múltiples statements y que la cuenta de la base de datos tenga privilegios suficientes.