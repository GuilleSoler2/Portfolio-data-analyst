# Ejercicio 2 — Comportamiento y Retención de Clientes

Análisis de una base de 500 clientes y su historial de pedidos: quién compra, cuánto, con qué frecuencia, y quién ha dejado de hacerlo.

## Preguntas resueltas

1. Número total de clientes
2. Clientes con al menos 1 pedido completado
3. Clientes sin ninguna compra completada
4. Media de pedidos por cliente comprador
5. Gasto medio por cliente comprador
6. Top 10 clientes por facturación (`ROW_NUMBER`)
7. Clientes con más de 5 pedidos
8. Clientes con gasto por encima de la media
9. Altas de clientes por mes
10. Clientes inactivos (sin compra en +6 meses)
11. Clientes con facturación creciente 2025 vs. 2024 (`LAG`)
12. Facturación por segmento de cliente
13. **Pregunta especial:** clientes que compraron en 2025 pero no en 2026, y cuánto facturaban

## Técnicas utilizadas

- `NOT EXISTS` vs. `NOT IN` aplicados en distintos contextos según el caso
- CTEs para aislar métricas por cliente antes de filtrar o comparar
- Función de ventana `LAG()` para comparar facturación año contra año por cliente
- Subquery correlacionada para comparar contra la media (`WHERE gasto_total > (SELECT AVG...)`)
- Lógica de churn: cruce de compradores por año para detectar clientes perdidos

## Resumen ejecutivo

- **500 clientes totales**; 417 han comprado alguna vez (83 nunca han comprado)
- Media de **8,12 pedidos** y **880,07 €** de gasto por cliente comprador
- **246 clientes** superan los 5 pedidos; **169** gastan por encima de la media
- **151 clientes inactivos** (sin comprar en los últimos 6 meses)
- **94 clientes** aumentaron su facturación en 2025 frente a 2024
- El segmento **Particular** concentra la mayor facturación (265.541,77 €), por volumen de clientes
- **107 clientes** activos en 2025 no volvieron a comprar en 2026 — **72.270,96 €** de facturación en riesgo, foco prioritario para una campaña de retención

## Archivo

[`Ejercicio_SQL_2_Clientes.sql`](./Ejercicio_SQL_2_Clientes.sql)
