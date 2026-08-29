-- Pregunta 1: Facturación total
SELECT ROUND(SUM(unidades * precio_unitario - descuento), 2) AS facturacion_total
FROM ventas;
-- Pregunta 2: Margen bruto total
SELECT ROUND(SUM(
    (v.unidades * v.precio_unitario - v.descuento) - (v.unidades * p.coste_unitario)
), 2) AS margen_bruto_total
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id;
-- Pregunta 3: Categoría con más ingresos
SELECT p.categoria,
       ROUND(SUM(v.unidades * v.precio_unitario - v.descuento), 2) AS facturacion
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY p.categoria
ORDER BY facturacion DESC;
-- Pregunta 4: Top 10 productos más vendidos (por unidades)
SELECT p.producto, p.categoria, SUM(v.unidades) AS unidades_vendidas
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY p.producto_id, p.producto, p.categoria
ORDER BY unidades_vendidas DESC
LIMIT 10;
-- Pregunta 5: Top 10 productos más rentables (por margen bruto en €)
SELECT p.producto, p.categoria,
       ROUND(SUM(
           (v.unidades * v.precio_unitario - v.descuento) - (v.unidades * p.coste_unitario)
       ), 2) AS margen_bruto
FROM ventas v
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY p.producto_id, p.producto, p.categoria
ORDER BY margen_bruto DESC
LIMIT 10;
-- Pregunta 6: Tienda con mayor facturación
SELECT t.tienda, t.ciudad,
       ROUND(SUM(v.unidades * v.precio_unitario - v.descuento), 2) AS facturacion
FROM ventas v
JOIN tiendas t ON t.tienda_id = v.tienda_id
GROUP BY t.tienda_id, t.tienda, t.ciudad
ORDER BY facturacion DESC;
-- Pregunta 7: Tienda con mayor margen porcentual
SELECT t.tienda,
       ROUND(SUM(
           (v.unidades * v.precio_unitario - v.descuento) - (v.unidades * p.coste_unitario)
       ), 2) AS margen_bruto,
       ROUND(SUM(v.unidades * v.precio_unitario - v.descuento), 2) AS facturacion,
       ROUND(100.0 * SUM(
           (v.unidades * v.precio_unitario - v.descuento) - (v.unidades * p.coste_unitario)
       ) / SUM(v.unidades * v.precio_unitario - v.descuento), 2) AS margen_pct
FROM ventas v
JOIN tiendas t ON t.tienda_id = v.tienda_id
JOIN productos p ON p.producto_id = v.producto_id
GROUP BY t.tienda_id, t.tienda
ORDER BY margen_pct DESC;
-- Pregunta 8: Ticket medio
SELECT ROUND(SUM(unidades * precio_unitario - descuento) / COUNT(*), 2) AS ticket_medio
FROM ventas;
-- Pregunta 9: Evolución mensual de ventas
SELECT strftime('%Y-%m', fecha) AS mes,
       ROUND(SUM(unidades * precio_unitario - descuento), 2) AS facturacion,
       SUM(unidades) AS unidades_vendidas
FROM ventas
GROUP BY mes
ORDER BY mes;
-- Pregunta 10: Productos con mucho volumen pero poco margen
-- (CTE en dos pasos + funciones ventana RANK)
WITH metrica_producto AS (
    SELECT p.producto_id, p.producto, p.categoria,
           SUM(v.unidades) AS unidades_vendidas,
           SUM(v.unidades * v.precio_unitario - v.descuento) AS facturacion,
           SUM(
               (v.unidades * v.precio_unitario - v.descuento) - (v.unidades * p.coste_unitario)
           ) AS margen_bruto
    FROM ventas v
    JOIN productos p ON p.producto_id = v.producto_id
    GROUP BY p.producto_id, p.producto, p.categoria
),
metrica_con_margen AS (
    SELECT *,
           ROUND(100.0 * margen_bruto / facturacion, 2) AS margen_pct
    FROM metrica_producto
),
rankeado AS (
    SELECT *,
           RANK() OVER (ORDER BY unidades_vendidas DESC) AS rank_ventas,
           RANK() OVER (ORDER BY margen_pct ASC) AS rank_margen
    FROM metrica_con_margen
)
SELECT producto, categoria, unidades_vendidas, margen_pct, rank_ventas, rank_margen
FROM rankeado
WHERE rank_ventas <= 15 AND rank_margen <= 15
ORDER BY rank_ventas;
--Resumen ejecutivo:
--Facturación total: 587.730,41 € — margen bruto total: 358.677,41 € (~61 %)
--Categoría líder en ingresos: Electrónica, seguida de Hogar
--Producto más vendido en unidades: Vestido verano mujer (569 uds.)
--Producto más rentable en € de margen: Robot aspirador básico (32.106,44 €)
--Tienda líder en facturación y margen %: Tienda Barcelona Centro
--Ticket medio: 60,29 €
--Estacionalidad marcada: picos en verano y, sobre todo, en la campaña de noviembre-diciembre; tendencia de crecimiento interanual
--4 productos identificados con alto volumen pero margen relativamente bajo: candidatos a revisión de pricing o coste
