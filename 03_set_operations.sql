-- Теоретико-множественные операции: UNION, INTERSECT, EXCEPT
-- Контекст: база данных розничного магазина

-- 1. UNION: единый список категорий и причин списания
SELECT name AS "Название" FROM category
UNION
SELECT name AS "Название" FROM write_off_reason
ORDER BY "Название";

-- 2. INTERSECT: товары, которые есть на складе И были проданы
SELECT p.name AS "Товар"
FROM product p
JOIN stock s ON p.id = s.product_id
INTERSECT
SELECT p.name AS "Товар"
FROM product p
JOIN stock s ON p.id = s.product_id
JOIN sale_item si ON s.id = si.stock_id
ORDER BY "Товар";

-- 3. EXCEPT: товары на складе, которые НЕ были проданы
SELECT p.name AS "Товар"
FROM product p
JOIN stock s ON p.id = s.product_id
EXCEPT
SELECT p.name AS "Товар"
FROM product p
JOIN stock s ON p.id = s.product_id
JOIN sale_item si ON s.id = si.stock_id
ORDER BY "Товар";
