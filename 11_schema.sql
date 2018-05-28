/*
  Создание схемы БД
  Используется в 'make create'
*/

-- Вывод в логи информации о коннекте
\conninfo

-- Создание схемы
CREATE SCHEMA IF NOT EXISTS :PKG;
