-- Работа с неструктурированными данными (JSONB) в PostgreSQL
-- Контекст: база данных розничного магазина

-- 1. Извлечение и фильтрация по полю JSONB
WITH expensive_sales AS (
    SELECT
        log_id,
        created_at,
        user_id,
        event_data,
        (event_data->'details'->>'total_sum')::numeric AS sale_sum
    FROM user_logs
    WHERE event_data->>'event' = 'sale'
      AND (event_data->'details'->>'total_sum')::numeric > 500
)
SELECT
    log_id AS "ID лога",
    created_at AS "Дата",
    user_id AS "ID пользователя",
    sale_sum AS "Сумма продажи"
FROM expensive_sales
ORDER BY sale_sum DESC;

-- 2. Массовое добавление нового поля во все JSON-документы
UPDATE user_logs
SET event_data = event_data || '{"source":"web"}'::jsonb;

-- Проверка результата
SELECT
    log_id,
    event_data->>'event' AS "Тип события",
    event_data->>'source' AS "Источник"
FROM user_logs
LIMIT 5;

-- 3. Точечное изменение значения внутри JSON через jsonb_set()
UPDATE user_logs
SET event_data = jsonb_set(
    event_data,
    '{details,quantity}',
    '100'::jsonb
)
WHERE log_id = (
    SELECT MIN(log_id)
    FROM user_logs
    WHERE event_data->>'event' = 'sale'
);

-- Проверка
SELECT
    log_id,
    event_data->'details'->'quantity' AS "Количество после изменения",
    event_data
FROM user_logs
WHERE event_data->>'event' = 'sale'
ORDER BY log_id
LIMIT 1;
