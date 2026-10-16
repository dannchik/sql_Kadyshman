-- Обобщённые табличные выражения (CTE)
-- Стандартное CTE и рекурсивное CTE
-- Контекст: база данных розничного магазина

-- 1. Стандартное CTE: переписываем запрос с EXISTS через CTE
WITH expensive_products AS (
    SELECT DISTINCT p.manufacturer_id
    FROM product p
    JOIN stock s ON p.id = s.product_id
    WHERE s.retail_price > 100
)
SELECT
    m.name AS "Производитель",
    m.inn AS "ИНН"
FROM manufacturer m
JOIN expensive_products ep ON m.id = ep.manufacturer_id
ORDER BY m.name;

-- 2. Рекурсивное CTE: иерархия категорий товаров
WITH RECURSIVE category_tree AS (
    -- Базовый случай: корневые категории
    SELECT
        category_id,
        name,
        parent_id,
        0 AS level
    FROM product_categories
    WHERE parent_id IS NULL

    UNION ALL

    -- Рекурсивный шаг: дочерние категории
    SELECT
        pc.category_id,
        pc.name,
        pc.parent_id,
        ct.level + 1
    FROM product_categories pc
    JOIN category_tree ct ON pc.parent_id = ct.category_id
)
SELECT
    REPEAT('  ', level) || name AS "Иерархия",
    level AS "Уровень"
FROM category_tree
ORDER BY level;
