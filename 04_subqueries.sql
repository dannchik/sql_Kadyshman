-- Подзапросы: скалярный, IN, EXISTS, коррелированный
-- Контекст: база данных розничного магазина

-- 1. Скалярный подзапрос: товары дороже средней цены по складу
SELECT
    p.name AS "Товар",
    s.batch_number AS "Партия",
    s.retail_price AS "Цена",
    (SELECT ROUND(AVG(retail_price), 2) FROM stock) AS "Средняя цена по складу"
FROM stock s
JOIN product p ON s.product_id = p.id
WHERE s.retail_price > (SELECT AVG(retail_price) FROM stock)
ORDER BY s.retail_price DESC;

-- 2. Многострочный подзапрос с IN: товары, проданные после определённой даты
SELECT DISTINCT
    p.name AS "Товар",
    p.barcode AS "Штрихкод",
    s.retail_price AS "Текущая цена"
FROM product p
JOIN stock s ON p.id = s.product_id
WHERE s.id IN (
    SELECT si.stock_id
    FROM sale_item si
    JOIN sale_header sh ON si.sale_header_id = sh.id
    WHERE sh.sale_date >= '2026-03-01'
)
ORDER BY p.name;

-- 3. Коррелированный подзапрос с EXISTS: производители с товарами дороже 100 руб.
SELECT DISTINCT
    m.name AS "Производитель",
    m.inn AS "ИНН"
FROM manufacturer m
WHERE EXISTS (
    SELECT 1
    FROM product p
    JOIN stock s ON p.id = s.product_id
    WHERE p.manufacturer_id = m.id
      AND s.retail_price > 100
);

-- 4. Альтернатива через JOIN (эквивалент EXISTS)
SELECT DISTINCT
    m.name AS "Производитель",
    m.inn AS "ИНН"
FROM manufacturer m
JOIN product p ON m.id = p.manufacturer_id
JOIN stock s ON p.id = s.product_id
WHERE s.retail_price > 100
ORDER BY m.name;
