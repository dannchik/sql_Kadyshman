-- Базовые операции SQL: SELECT, WHERE, GROUP BY, UPDATE, DELETE
-- Контекст: база данных розничного магазина


-- 1. Полная выборка из справочника
SELECT * FROM country;

-- 2. Расчёт потенциальной выручки от продаж всех остатков на складе
SELECT
    batch_number AS "Номер партии",
    quantity AS "Остаток, шт.",
    retail_price AS "Цена за шт.",
    quantity * retail_price AS "Общая стоимость партии"
FROM stock;

-- 3. Уникальные статусы инвентаризации
SELECT DISTINCT status FROM inventory_header;

-- 4. Фильтрация по диапазону цен и количеству
SELECT *
FROM stock
WHERE retail_price BETWEEN 50 AND 200
  AND quantity > 20;

-- 5. Поиск по нескольким категориям с LIKE
SELECT name, category_id
FROM product
WHERE category_id IN (1, 5)
  AND name LIKE '%Молоко%';

-- 6. Чеки без карты лояльности
SELECT id AS "Номер чека", sale_date, total_amount
FROM sale_header
WHERE loyalty_card_id IS NULL;

-- 7. GROUP BY: статистика по категориям
SELECT
    c.name AS "Категория",
    COUNT(p.id) AS "Количество партий",
    AVG(s.retail_price) AS "Средняя цена",
    MIN(s.retail_price) AS "Мин. цена",
    MAX(s.retail_price) AS "Макс. цена"
FROM product p
JOIN category c ON p.category_id = c.id
JOIN stock s ON p.id = s.product_id
GROUP BY c.name;

-- 8. HAVING: категории с >1 партией и средней ценой > 100 руб.
SELECT
    c.name AS "Категория",
    COUNT(p.id) AS "Количество партий",
    AVG(s.retail_price) AS "Средняя цена"
FROM product p
JOIN category c ON p.category_id = c.id
JOIN stock s ON p.id = s.product_id
GROUP BY c.name
HAVING COUNT(p.id) > 1 AND AVG(s.retail_price) > 100;

-- 9. ORDER BY: сортировка партий (от дорогих к дешёвым)
SELECT
    p.name AS "Товар",
    s.batch_number AS "Партия",
    s.retail_price AS "Цена"
FROM stock s
JOIN product p ON s.product_id = p.id
ORDER BY s.retail_price DESC, p.name ASC;

-- 10. UPDATE: точечное обновление статуса инвентаризации
UPDATE inventory_header
SET status = 'Утверждена'
WHERE id = 1;

-- 11. UPDATE: массовое изменение минимального остатка для скоропортящихся
UPDATE product
SET min_stock_level = 50
WHERE is_perishable = true;

-- 12. DELETE: удаление черновиков инвентаризации старше определённой даты
DELETE FROM inventory_header
WHERE status = 'Черновик'
  AND inventory_date < '2026-03-10';

-- 13. DELETE: удаление конкретной позиции списания
DELETE FROM write_off_item
WHERE write_off_id = 10 AND stock_id = 1;
