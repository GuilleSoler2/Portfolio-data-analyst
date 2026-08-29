-- Pregunta 1: Evolución mensual de la facturación
SELECT strftime('%Y-%m', fecha) AS mes,
       ROUND(SUM(unidades * precio_unitario - descuento), 2) AS facturacion
FROM ventas
GROUP BY mes
ORDER BY mes;
-- Pregunta 2: Evolución mensual del margen bruto y del margen %
SELECT strftime('%Y-%m', v.fecha) AS mes,
       ROUND(SUM((v.unidades * v.precio_unitario - v.descuento) - v.unidades * p.coste_unitario), 2) AS margen_bruto,
       ROUND(100.0 * SUM((v.unidades * v.precio_unitario - v.descuento) - v.unidades * p.coste_unitario)
             / SUM(v.unidades * v.precio_unitario - v.descuento), 2) AS margen_pct
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY mes
ORDER BY mes;
-- Preguntas 3 y 4: Tiendas en crecimiento vs tiendas en declive (YoY ene-ago)
WITH ventas_2025 AS (
    SELECT tienda_id, SUM(unidades * precio_unitario - descuento) AS ventas_2025
    FROM ventas
    WHERE fecha BETWEEN '2025-01-01' AND '2025-08-20'
    GROUP BY tienda_id
),
ventas_2026 AS (
    SELECT tienda_id, SUM(unidades * precio_unitario - descuento) AS ventas_2026
    FROM ventas
    WHERE fecha BETWEEN '2026-01-01' AND '2026-08-20'
    GROUP BY tienda_id
)
SELECT t.tienda,
       ROUND(100.0 * (v26.ventas_2026 - v25.ventas_2025) / v25.ventas_2025, 2) AS crecimiento_pct,
       CASE WHEN v26.ventas_2026 > v25.ventas_2025 THEN 'Creciendo' ELSE 'Empeorando' END AS estado
FROM tiendas t
JOIN ventas_2025 v25 ON v25.tienda_id = t.tienda_id
JOIN ventas_2026 v26 ON v26.tienda_id = t.tienda_id
ORDER BY crecimiento_pct DESC;
-- Comparación 2025 vs 2026 por tienda (tabla completa)
WITH ventas_2025 AS (
    SELECT tienda_id, SUM(unidades * precio_unitario - descuento) AS ventas_2025
    FROM ventas WHERE fecha BETWEEN '2025-01-01' AND '2025-08-20'
    GROUP BY tienda_id
),
ventas_2026 AS (
    SELECT tienda_id, SUM(unidades * precio_unitario - descuento) AS ventas_2026
    FROM ventas WHERE fecha BETWEEN '2026-01-01' AND '2026-08-20'
    GROUP BY tienda_id
)
SELECT t.tienda,
       ROUND(v25.ventas_2025, 2) AS ventas_2025,
       ROUND(v26.ventas_2026, 2) AS ventas_2026,
       ROUND(v26.ventas_2026 - v25.ventas_2025, 2) AS diferencia_absoluta,
       ROUND(100.0 * (v26.ventas_2026 - v25.ventas_2025) / v25.ventas_2025, 2) AS crecimiento_pct
FROM tiendas t
JOIN ventas_2025 v25 ON v25.tienda_id = t.tienda_id
JOIN ventas_2026 v26 ON v26.tienda_id = t.tienda_id
ORDER BY crecimiento_pct DESC;
-- Pregunta final: cuadrante ventas x margen por tienda
WITH datos AS (
    SELECT v.tienda_id,
           CASE WHEN v.fecha BETWEEN '2025-01-01' AND '2025-08-20' THEN '2025'
                WHEN v.fecha BETWEEN '2026-01-01' AND '2026-08-20' THEN '2026' END AS periodo,
           SUM(v.unidades * v.precio_unitario - v.descuento) AS facturacion,
           SUM((v.unidades * v.precio_unitario - v.descuento) - v.unidades * p.coste_unitario) AS margen
    FROM ventas v
    JOIN productos p ON p.producto_id = v.producto_id
    WHERE v.fecha BETWEEN '2025-01-01' AND '2025-08-20'
       OR v.fecha BETWEEN '2026-01-01' AND '2026-08-20'
    GROUP BY v.tienda_id, periodo
),
pivot AS (
    SELECT tienda_id,
        MAX(CASE WHEN periodo='2025' THEN facturacion END) AS facturacion_2025,
        MAX(CASE WHEN periodo='2026' THEN facturacion END) AS facturacion_2026,
        MAX(CASE WHEN periodo='2025' THEN margen END) AS margen_2025,
        MAX(CASE WHEN periodo='2026' THEN margen END) AS margen_2026
    FROM datos GROUP BY tienda_id
),
cuadrante AS (
    SELECT t.tienda,
           ROUND(100.0*(facturacion_2026-facturacion_2025)/facturacion_2025, 2) AS var_ventas_pct,
           ROUND(100.0*margen_2026/facturacion_2026 - 100.0*margen_2025/facturacion_2025, 2) AS var_margen_puntos
    FROM pivot p JOIN tiendas t ON t.tienda_id = p.tienda_id
)
SELECT tienda, var_ventas_pct, var_margen_puntos,
       CASE
           WHEN var_ventas_pct > 0 AND var_margen_puntos > 0 THEN 'Crecimiento sano'
           WHEN var_ventas_pct > 0 AND var_margen_puntos < 0 THEN '⚠ Ventas ↑ pero margen ↓'
           WHEN var_ventas_pct < 0 AND var_margen_puntos > 0 THEN '⚠ Ventas ↓ pero margen ↑'
           ELSE 'Deterioro'
       END AS diagnostico
FROM cuadrante
ORDER BY var_ventas_pct DESC;
--Profundizando en Blanes: margen neto real (bruto - costes operativos)
SELECT t.tienda, vp.periodo,
       ROUND(vp.margen_bruto, 2) AS margen_bruto,
       ROUND(cp.costes_totales, 2) AS costes_operativos,
       ROUND(vp.margen_bruto - cp.costes_totales, 2) AS margen_neto
FROM ventas_periodo vp   
-- (CTE análoga a la de más arriba, con margen bruto por periodo)
JOIN costes_periodo cp ON cp.tienda_id = vp.tienda_id AND cp.periodo = vp.periodo
JOIN tiendas t ON t.tienda_id = vp.tienda_id
WHERE t.tienda = 'Tienda Blanes';
-- Conclusion:Esto es lo que le respondería a un manager que preguntó "¿estamos realmente mejorando?" — en lenguaje de negocio, no de SQL:
--1. El crecimiento agregado es real pero desigual: la facturación total sube (~+2 % interanual, arrastrada por Barcelona Centro), pero 5 de las 10 tiendas están en realidad cayendo. "Las ventas crecen" es cierto a nivel de compañía y falso a nivel de la mitad de la red.
--2. No todo crecimiento es bueno: Tienda Blanes crece un 24,6 % en ventas pero ha necesitado multiplicar por 2,6 su inversión en marketing/promoción para conseguirlo, y su margen % ha bajado 3,3 puntos. Ese crecimiento no es gratis — hay que decidir si es una inversión estratégica temporal o un problema de rentabilidad estructural.
--3. No toda caída es mala: Tienda Online factura un 8,2 % menos, pero gana más dinero neto que el año pasado gracias a subir precios y recortar descuentos. Si se juzgara solo por la cifra de ventas, se penalizaría a la tienda que mejor está gestionando su rentabilidad.
--4. Madrid Centro es la urgencia real: cae un 47,77 % en ventas Y pierde margen al mismo tiempo — es la única tienda en "deterioro" puro (sin ninguna métrica compensando a la otra). Es la que debería recibir atención prioritaria, no Blanes ni Online, que al menos tienen una explicación estratégica detrás.
--5. Recomendación: sustituir el KPI único de "facturación" en los informes de dirección por un cuadro de mando de al menos dos ejes (ventas + margen, idealmente margen neto), para no confundir crecimiento de ingresos con creación de valor. Este mismo cruce de 4 cuadrantes usado en la pregunta final podría convertirse en un informe mensual recurrente.
