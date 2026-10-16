-- Все типы JOIN в PostgreSQL
-- Контекст: база данных розничного магазина


-- 1. INNER JOIN: полное объединение stock и product
SELECT *
FROM stock s
INNER JOIN product p ON s.product_id = p.id;

-- 2. LEFT JOIN: все товары, включая те, у которых нет остатков на складе
SELECT
    p.name AS "Товар",
    p.barcode AS "Штрихкод",
    s.batch_number AS "Партия",
    s.quantity AS "Остаток на складе"
FROM product p
LEFT JOIN stock s ON p.id = s.product_id
ORDER BY p.name;

-- 3. RIGHT JOIN + IS NULL: товары без производителя в базе
SELECT
    m.name AS "Производитель",
    m.inn AS "ИНН",
    p.name AS "Товар"
FROM stock s
RIGHT JOIN product p ON s.product_id = p.id
RIGHT JOIN manufacturer m ON p.manufacturer_id = m.id
WHERE s.id IS NULL;

-- 4. FULL JOIN: все страны и производители, включая несвязанные
SELECT
    COALESCE(c.name, 'Страна не указана') AS "Страна",
    COALESCE(m.name, 'Производитель не указан') AS "Производитель",
    COUNT(m.id) AS "Количество производителей"
FROM country c
FULL JOIN manufacturer m ON c.id = m.country_id
GROUP BY c.name, m.name
ORDER BY "Количество производителей" DESC;

-- 5. CROSS JOIN: все комбинации магазинов и способов оплаты
SELECT
    s.name AS "Магазин",
    pt.name AS "Способ оплаты"
FROM store s
CROSS JOIN payment_type pt
ORDER BY s.name, pt.name;

-- 6. SELF-JOIN: сотрудники одного магазина
SELECT
    e1.full_name AS "Сотрудник 1",
    e2.full_name AS "Сотрудник 2",
    e1.position AS "Должность 1",
    e2.position AS "Должность 2",
    st.name AS "Магазин"
FROM employee e1
JOIN employee e2 ON e1.store_id = e2.store_id
JOIN store st ON e1.store_id = st.id
WHERE e1.id < e2.id
ORDER BY st.name, e1.full_name;

-- 7. Сложный запрос: цепочка из 7 таблиц (клиент → карта → уровень → чек → позиция → склад → товар)
SELECT
    (c.full_name).last_name AS "Фамилия клиента",
    lc.card_number AS "Номер карты",
    ll.level_name AS "Уровень лояльности",
    ll.discount_percent AS "Скидка %",
    sh.sale_date AS "Дата продажи",
    sh.total_amount AS "Сумма чека",
    p.name AS "Товар",
    si.quantity AS "Количество"
FROM client c
JOIN loyalty_card lc ON c.id = lc.client_id
JOIN loyalty_level ll ON lc.level_id = ll.id
JOIN sale_header sh ON lc.id = sh.loyalty_card_id
JOIN sale_item si ON sh.id = si.sale_header_id
JOIN stock st ON si.stock_id = st.id
JOIN product p ON st.product_id = p.id
ORDER BY sh.sale_date DESC, c.id;
