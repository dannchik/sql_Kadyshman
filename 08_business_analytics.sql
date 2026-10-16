-- Реальные бизнес-задачи банковской аналитики


-- Задание 1.1: Уникальные коды продуктов, выданных в мае
SELECT DISTINCT PRODUCT_CODE
FROM U_M1TPH.LOGIST_REWIE
WHERE DATE_DELIVERY >= '2025-05-01'
  AND DATE_DELIVERY < '2025-06-01';

-- Задание 1.2: Количество выдач дебетовых карт (DC) сотрудниками штата по дням
SELECT
    DATE_DELIVERY,
    COUNT(*) AS issued_count
FROM U_M1TPH.LOGIST_REWIE
WHERE DATE_DELIVERY >= '2025-05-01'
  AND DATE_DELIVERY < '2025-06-01'
  AND PRODUCT_CODE = 'DC'
  AND TYPE = 'STAFF'
GROUP BY DATE_DELIVERY
ORDER BY DATE_DELIVERY;

-- Задание 1.3: Дни с выдачами менее 10 000 (проверка теории о выходных)
SELECT
    DATE_DELIVERY,
    COUNT(*) AS issued_count
FROM U_M1TPH.LOGIST_REWIE
WHERE DATE_DELIVERY >= '2025-05-01'
  AND DATE_DELIVERY < '2025-06-01'
  AND PRODUCT_CODE = 'DC'
  AND TYPE = 'STAFF'
GROUP BY DATE_DELIVERY
HAVING COUNT(*) < 10000
ORDER BY DATE_DELIVERY;

-- Задание 2: Выдачи кредитных и дебетовых карт сотрудниками управления SME
SELECT
    lr.EXTERNAL_ID,
    lr.DATE_DELIVERY,
    lr.PRODUCT_CODE,
    lr.CITY,
    lr.REGION,
    lr.LOGIN,
    lr.TYPE,
    dr.EMPLOYEE_NUMBER,
    dr.USER_ID,
    dr.EMPLOYEE_NAME,
    dr.DIVISION,
    dr.EXPERIENCE_CASE
FROM U_M1TPH.LOGIST_REWIE lr
LEFT JOIN U_M1TPH.DPP_DELIVERY_REWIE dr
    ON lr.LOGIN = dr.USER_ID
   AND lr.DATE_DELIVERY = dr.DATE_REPORT
WHERE lr.DATE_DELIVERY >= '2025-05-01'
  AND lr.DATE_DELIVERY < '2025-06-01'
  AND lr.PRODUCT_CODE IN ('CC', 'CC2', 'DC')
  AND dr.DIVISION = 'SME'
  AND dr.DATE_REPORT >= '2025-05-01'
  AND dr.DATE_REPORT < '2025-06-01';

-- Задание 2.1: Последняя запись по каждому сотруднику (оконные функции)
-- Решает проблему увольнения: сотрудник перестаёт быть в справочнике
WITH last AS (
    SELECT
        DATE_REPORT,
        EMPLOYEE_NUMBER,
        USER_ID,
        EMPLOYEE_NAME,
        DIVISION,
        EXPERIENCE_CASE,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID
            ORDER BY DATE_REPORT DESC
        ) AS rn
    FROM U_M1TPH.DPP_DELIVERY_REWIE
)
SELECT
    DATE_REPORT,
    EMPLOYEE_NUMBER,
    USER_ID,
    EMPLOYEE_NAME,
    DIVISION,
    EXPERIENCE_CASE
FROM last
WHERE rn = 1
ORDER BY EMPLOYEE_NUMBER;
