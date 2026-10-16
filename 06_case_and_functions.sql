-- Оператор CASE, строковые, датные и математические функции
-- Контекст: база данных розничного магазина

-- 1. CASE: категоризация товаров по сроку годности
SELECT
    p.name AS "Товар",
    s.batch_number AS "Партия",
    s.expiration_date AS "Срок годности",
    s.quantity AS "Остаток",
    CASE
        WHEN s.expiration_date < CURRENT_DATE
            THEN 'ПРОСРОЧЕН'
        WHEN s.expiration_date < CURRENT_DATE + INTERVAL '7 days'
            THEN 'Требует внимания (менее 7 дней)'
        WHEN s.expiration_date < CURRENT_DATE + INTERVAL '30 days'
            THEN 'Скоро истекает (менее 30 дней)'
        ELSE 'Свежий'
    END AS "Статус свежести"
FROM stock s
JOIN product p ON s.product_id = p.id
ORDER BY s.expiration_date ASC;

-- 2. CASE внутри агрегатной функции: условная агрегация по ценовым сегментам
SELECT
    st.name AS "Магазин",
    COUNT(CASE WHEN s.retail_price < 100 THEN 1 END) AS "Дешёвые (<100₽)",
    COUNT(CASE WHEN s.retail_price BETWEEN 100 AND 500 THEN 1 END) AS "Средние (100-500₽)",
    COUNT(CASE WHEN s.retail_price > 500 THEN 1 END) AS "Дорогие (>500₽)",
    COUNT(*) AS "Всего партий"
FROM stock s
JOIN store st ON s.store_id = st.id
GROUP BY st.name
ORDER BY st.name;

-- 3. Строковые функции, функции дат и математические функции
SELECT
    UPPER(CONCAT((c.full_name).last_name, ' ', (c.full_name).first_name)) AS "ФИО клиента (ВЕРХНИЙ РЕГИСТР)",
    LENGTH((c.full_name).last_name) AS "Длина фамилии",
    SUBSTRING(c.email FROM 1 FOR POSITION('@' IN c.email) - 1) AS "Логин из email",
    CURRENT_DATE AS "Дата отчёта",
    AGE(c.birth_date) AS "Возраст клиента",
    EXTRACT(YEAR FROM c.birth_date) AS "Год рождения",
    ROUND(COALESCE(
        (SELECT SUM(sh.total_amount)
         FROM loyalty_card lc
         JOIN sale_header sh ON lc.id = sh.loyalty_card_id
         WHERE lc.client_id = c.id), 0), 2) AS "Сумма покупок",
    CEIL(COALESCE(
        (SELECT AVG(sh.total_amount)
         FROM loyalty_card lc
         JOIN sale_header sh ON lc.id = sh.loyalty_card_id
         WHERE lc.client_id = c.id), 0)) AS "Средний чек (округлённый вверх)"
FROM client c
WHERE c.birth_date IS NOT NULL
ORDER BY c.id;
