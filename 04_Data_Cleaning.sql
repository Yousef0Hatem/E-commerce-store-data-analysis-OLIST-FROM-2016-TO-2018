/*==============================================================
  OLIST E-COMMERCE ANALYSIS
  FILE: 04_Data_Cleaning.sql
  PURPOSE: Cleaning operations applied only after the quality
           checks confirm the required action.
==============================================================*/

/*==============================================================
  1. PRODUCT CATEGORY TRANSLATION
==============================================================*/

-- Rename translation columns using SQL Server syntax.
EXEC sp_rename
    'product_category_name_translation.COLUMN1',
    'CATEGORY_PORTUGUESE',
    'COLUMN';

EXEC sp_rename
    'product_category_name_translation.COLUMN2',
    'CATEGORY_ENGLISH',
    'COLUMN';

-- Verify the renamed columns.
SELECT *
FROM product_category_name_translation;

-- Preview the mapping before updating the products table.
SELECT
    p.product_category_name AS current_category,
    t.CATEGORY_ENGLISH AS translated_category
FROM products AS p
JOIN product_category_name_translation AS t
    ON p.product_category_name = t.CATEGORY_PORTUGUESE;

-- Apply the English category names to products.
UPDATE p
SET p.product_category_name = t.CATEGORY_ENGLISH
FROM products AS p
JOIN product_category_name_translation AS t
    ON p.product_category_name = t.CATEGORY_PORTUGUESE;

-- Verify the update.
SELECT
    p.product_category_name,
    t.CATEGORY_ENGLISH
FROM products AS p
JOIN product_category_name_translation AS t
    ON p.product_category_name = t.CATEGORY_ENGLISH;

-- Optional: remove the translation table only after verification.
-- DROP TABLE product_category_name_translation;

/*==============================================================
  2. NULL CLEANING
==============================================================
  Do not blindly delete every NULL. The original analysis showed
  that many order date NULLs are driven by the order status.

  The following query is a targeted example for removing an
  unneeded review comment column with a very high NULL rate.
==============================================================*/

-- Execute only if the business decision is to permanently remove
-- this mostly-empty field.
-- ALTER TABLE order_reviews
-- DROP COLUMN review_comment_title;

/*==============================================================
  3. GEOLOCATION DUPLICATE CLEANING
==============================================================
  The source analysis identified exact duplicate location records
  using the full location attributes, not ZIP code alone.
==============================================================*/

-- Preview duplicate rows with ROW_NUMBER().
WITH Duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                geolocation_zip_code_prefix,
                geolocation_lat,
                geolocation_lng,
                geolocation_city,
                geolocation_state
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM geolocation
)
SELECT *
FROM Duplicates
WHERE rn > 1
ORDER BY rn DESC;

-- Delete only exact duplicate records, keeping the first row.
-- Run only after reviewing the preview above.
WITH Duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                geolocation_zip_code_prefix,
                geolocation_lat,
                geolocation_lng,
                geolocation_city,
                geolocation_state
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM geolocation
)
DELETE FROM Duplicates
WHERE rn > 1;

/*==============================================================
  4. CITY NAME STANDARDIZATION
==============================================================*/

-- Preview accent normalization before applying it.
SELECT
    geolocation_city AS old_city,
    TRANSLATE(
        geolocation_city,
        'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
        'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'
    ) AS new_city
FROM geolocation;

-- Apply accent normalization.
UPDATE geolocation
SET geolocation_city =
    TRANSLATE(
        geolocation_city,
        'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
        'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'
    );

-- Preview the final values.
SELECT DISTINCT geolocation_city
FROM geolocation
ORDER BY geolocation_city;
