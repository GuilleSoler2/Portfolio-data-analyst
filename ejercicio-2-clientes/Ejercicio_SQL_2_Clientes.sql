-- Pregunta 1: Número total de clientes
SELECT COUNT(*) AS total_clientes
FROM clientes;
-- Pregunta 2: Clientes con al menos 1 pedido completado
SELECT COUNT(DISTINCT cliente_id) AS clientes_compradores
FROM pedidos
WHERE estado = 'completado';
-- Pregunta 3: Clientes sin ninguna compra completada
SELECT COUNT(*) AS clientes_sin_compras
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.cliente_id = c.cliente_id AND p.estado = 'completado'
);
-- Pregunta 4: Media de pedidos por cliente (entre los que compraron)
WITH pedidos_por_cliente AS (
    SELECT cliente_id, COUNT(*) AS n_pedidos
    FROM pedidos
    WHERE estado = 'completado'
    GROUP BY cliente_id
)
SELECT ROUND(AVG(n_pedidos), 2) AS media_pedidos_por_cliente_comprador
FROM pedidos_por_cliente;
-- Pregunta 5: Gasto medio por cliente (entre los que compraron)
WITH gasto_por_cliente AS (
    SELECT cliente_id, SUM(importe) AS gasto_total
    FROM pedidos
    WHERE estado = 'completado'
    GROUP BY cliente_id
)
SELECT ROUND(AVG(gasto_total), 2) AS gasto_medio_por_cliente
FROM gasto_por_cliente;
-- Pregunta 6: Top 10 clientes por facturación (con ROW_NUMBER)
WITH facturacion_cliente AS (
    SELECT c.cliente_id, c.ciudad, c.segmento,
           SUM(p.importe) AS facturacion
    FROM pedidos p
    JOIN clientes c ON c.cliente_id = p.cliente_id
    WHERE p.estado = 'completado'
    GROUP BY c.cliente_id, c.ciudad, c.segmento
),
ranking AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY facturacion DESC) AS ranking
    FROM facturacion_cliente
)
SELECT cliente_id, ciudad, segmento, facturacion, ranking
FROM ranking
WHERE ranking <= 10
ORDER BY ranking;
-- Pregunta 7: Clientes con más de X pedidos (X = 5)
SELECT cliente_id, COUNT(*) AS n_pedidos
FROM pedidos
WHERE estado = 'completado'
GROUP BY cliente_id
HAVING COUNT(*) > 5
ORDER BY n_pedidos DESC;
-- Pregunta 8: Clientes con gasto por encima de la media
WITH gasto_por_cliente AS (
    SELECT cliente_id, SUM(importe) AS gasto_total
    FROM pedidos
    WHERE estado = 'completado'
    GROUP BY cliente_id
)
SELECT cliente_id, gasto_total
FROM gasto_por_cliente
WHERE gasto_total > (SELECT AVG(gasto_total) FROM gasto_por_cliente)
ORDER BY gasto_total DESC;
-- Pregunta 9: Altas de clientes por mes
SELECT strftime('%Y-%m', fecha_registro) AS mes, COUNT(*) AS nuevos_clientes
FROM clientes
GROUP BY mes
ORDER BY mes;
-- Pregunta 10: Clientes inactivos (última compra hace > 6 meses)
WITH ultima_compra AS (
    SELECT cliente_id, MAX(fecha) AS fecha_ultima_compra
    FROM pedidos
    WHERE estado = 'completado'
    GROUP BY cliente_id
)
SELECT COUNT(*) AS clientes_inactivos
FROM ultima_compra
WHERE fecha_ultima_compra < date('2026-08-24', '-6 months');
-- Pregunta 11: Clientes con facturación creciente (2025 vs 2024, con LAG)
WITH facturacion_anual AS (
    SELECT cliente_id, CAST(strftime('%Y', fecha) AS INTEGER) AS anio,
           SUM(importe) AS facturacion
    FROM pedidos
    WHERE estado = 'completado' AND strftime('%Y', fecha) IN ('2024','2025')
    GROUP BY cliente_id, anio
),
comparativa AS (
    SELECT cliente_id, anio, facturacion,
           LAG(facturacion) OVER (PARTITION BY cliente_id ORDER BY anio)
               AS facturacion_anio_anterior
    FROM facturacion_anual
)
SELECT cliente_id, facturacion_anio_anterior, facturacion,
       CASE WHEN facturacion > facturacion_anio_anterior THEN 'Aumento'
            WHEN facturacion < facturacion_anio_anterior THEN 'Descenso'
            ELSE 'Estable' END AS tendencia
FROM comparativa
WHERE anio = 2025 AND facturacion_anio_anterior IS NOT NULL;
-- Pregunta 12: Facturación por segmento de cliente
SELECT c.segmento, ROUND(SUM(p.importe), 2) AS facturacion
FROM pedidos p
JOIN clientes c ON c.cliente_id = p.cliente_id
WHERE p.estado = 'completado'
GROUP BY c.segmento
ORDER BY facturacion DESC;
-- Pregunta especial: clientes que compraron en 2025 pero no en 2026
-- + cuánto dinero generaban esos clientes
WITH compradores_2025 AS (
    SELECT DISTINCT cliente_id
    FROM pedidos
    WHERE estado = 'completado' AND strftime('%Y', fecha) = '2025'
),
compradores_2026 AS (
    SELECT DISTINCT cliente_id
    FROM pedidos
    WHERE estado = 'completado' AND strftime('%Y', fecha) = '2026'
),
clientes_perdidos AS (
    SELECT cliente_id FROM compradores_2025
    WHERE cliente_id NOT IN (SELECT cliente_id FROM compradores_2026)
)
SELECT COUNT(DISTINCT p.cliente_id) AS n_clientes_perdidos,
       ROUND(SUM(p.importe), 2) AS facturacion_2025_generada
FROM pedidos p
WHERE p.estado = 'completado'
  AND strftime('%Y', p.fecha) = '2025'
  AND p.cliente_id IN (SELECT cliente_id FROM clientes_perdidos);
--Resumen ejecutivo
--500 clientes totales; 417 han comprado alguna vez (83 nunca han comprado)
--Media de 8,12 pedidos y 880,07 € de gasto por cliente comprador
--246 clientes superan los 5 pedidos; 169 gastan por encima de la media
--151 clientes están inactivos (sin comprar en los últimos 6 meses)
--94 clientes aumentaron su facturación en 2025 frente a 2024
--El segmento Particular concentra la mayor facturación (265.541,77 €), por volumen de clientes
--107 clientes activos en 2025 no han vuelto a comprar en 2026 — 72.270,96 € de facturación en riesgo, foco prioritario para una campaña de retención
