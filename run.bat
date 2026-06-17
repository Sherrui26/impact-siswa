@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-21"
echo JAVA_HOME=%JAVA_HOME%
call mvnw.cmd jetty:run
