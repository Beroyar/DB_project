-- Домашнее задание Шугурина А. к уроку 3
-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
USE shop;
UPDATE users -- Очищаем поля created_at и updated_at
SET created_at = NULL, 
	updated_at = NULL;
UPDATE users -- Заполняем поля текущей датой
SET created_at = now(),
	updated_at = now()
WHERE created_at is NULL AND updated_at is NULL;
SELECT * FROM users;

-- 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время 
-- помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

USE shop;
DROP TABLE IF EXISTS old_users; -- Удаляем старую версию временной таблицы
CREATE TABLE old_users (
	id BIGINT SIGNED,
	name VARCHAR(255) COMMENT 'Имя покупателя',
	birthday_at DATE COMMENT 'Дата рождения',
	created_at VARCHAR(20),
	updated_at VARCHAR(20)
	);
-- Заполняем временную таблицу данными, сконвертированными в строки
INSERT INTO old_users (
	SELECT 
		id, name, birthday_at, CAST(created_at as CHAR) as created_at, CAST(updated_at as CHAR) as updated_at
	FROM users);
-- Проверяем, что получилось...
DESC old_users;
SELECT * FROM old_users;
ALTER TABLE old_users CHANGE created_at created_at DATETIME; -- Далее, я должен преобразовать поля shop.users.created_at в формат DATETIME, 
-- но делаю это на shop.old_users.created_at. На примере заметил, что преобразование типа поля происходит безболезненно для данных, так как в 
-- основе лежит все тот же строковый формат данных. Эту процедуру провожу и расписываю исключительно в учебных целях. 
-- ALTER TABLE users CHANGE updated_at updated_at DATETIME; -- Не был уверен в синтаксисе и сделал преобразование в два запроса
-- После чего перезаливаю данные из (shop.old_usrs.created_at и shop.old_users.updated_at) в (shop.users.created_at и shop.users.updated_at) с проверкой по id
INSERT INTO users (
	SELECT 
		str_to_date(created_at, '%d/%m/%y %H:%i') as created_at, str_to_date(updated_at, '%d/%m/%y %H:%i') as updated_at
	FROM old_users
    WHERE old_users.id = users.id
    );

-- Задание 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар 
-- закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они выводились в 
-- порядке увеличения значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.

SELECT * FROM storehouses_products; -- ПустоЮ однако...
INSERT INTO storehouses_products
  (storehouse_id, product_id, value, created_at, updated_at)
VALUES
  (1, 01322222, 2500, now(), now()),
  (1, 01322223, 30, now(), now()),
  (1, 01322224, 500, now(), now()),
  (1, 01322225, 0, now(), now()),
  (1, 01322226, 0, now(), now()),
  (1, 01322227, 1, now(), now()),
  (1, 01322228, 100, now(), now());

SELECT product_id, value
FROM storehouses_products
ORDER BY 
	CASE 
	WHEN value = 0
    THEN value = 65535
	END,
value;
    
 -- Задание 4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')
 SELECT name, birthday_at, monthname(birthday_at) 
 FROM users
 WHERE monthname(birthday_at) in ('May', 'August');
 
 -- Задание 5. Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
SELECT *
FROM catalogs
WHERE id in (5, 1, 2)
ORDER BY id = 5 DESC, id = 1 DESC, id = 2 DESC;
	
    -- Так и не понял почему не работает эта конструкция, указанная ниже. Думаю, что из-за конструкции auto_incremental
    -- CASE
		-- WHEN id = 5 THEN id = 1
        -- WHEN id = 1 THEN id = 2
        -- WHEN id = 2 THEN id = 3
	-- END,
    -- id DESC;