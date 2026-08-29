# Ejercicio 1 — Análisis Retail

Análisis de ventas, márgenes y catálogo de productos de una cadena retail con varias tiendas.

## Preguntas resueltas

1. Facturación total
2. Margen bruto total
3. Categoría con más ingresos
4. Top 10 productos más vendidos (por unidades)
5. Top 10 productos más rentables (por margen en €)
6. Tienda con mayor facturación
7. Tienda con mayor margen porcentual
8. Ticket medio
9. Evolución mensual de ventas
10. Productos con mucho volumen pero poco margen (CTEs + `RANK()`)

## Técnicas utilizadas

- Agregaciones (`SUM`, `COUNT`, `ROUND`) combinadas con `JOIN` entre ventas, productos y tiendas
- CTEs encadenadas para calcular métricas intermedias antes de rankear
- Funciones de ventana (`RANK() OVER`) para cruzar dos rankings distintos (volumen vs. margen) y detectar productos problemáticos
- `strftime()` para series temporales mensuales

## Resumen ejecutivo

- **Facturación total:** 587.730,41 € — **Margen bruto total:** 358.677,41 € (~61 %)
- **Categoría líder en ingresos:** Electrónica, seguida de Hogar
- **Producto más vendido (unidades):** Vestido verano mujer (569 uds.)
- **Producto más rentable (€ de margen):** Robot aspirador básico (32.106,44 €)
- **Tienda líder en facturación y margen %:** Tienda Barcelona Centro
- **Ticket medio:** 60,29 €
- **Estacionalidad:** picos en verano y, sobre todo, en campaña de noviembre-diciembre; tendencia de crecimiento interanual
- **4 productos** identificados con alto volumen pero margen relativamente bajo: candidatos a revisión de pricing o coste

## Archivo

[`Ejercicio_SQL_1_Retail.sql`](./Ejercicio_SQL_1_Retail.sql)
