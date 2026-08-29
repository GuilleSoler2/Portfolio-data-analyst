# Ejercicio 3 — Rendimiento por Tienda (Ventas vs. Margen)

Análisis comparativo interanual (2025 vs. 2026) por tienda, cruzando crecimiento en ventas con evolución del margen para distinguir crecimiento sano de crecimiento "de mentira".

## Preguntas resueltas

1. Evolución mensual de la facturación
2. Evolución mensual del margen bruto y del margen %
3-4. Tiendas en crecimiento vs. tiendas en declive (YoY enero-agosto)
5. Comparación completa 2025 vs. 2026 por tienda
6. **Cuadrante ventas × margen:** clasificación de cada tienda en Crecimiento sano / Ventas↑ margen↓ / Ventas↓ margen↑ / Deterioro
7. Caso de profundización: margen neto real de Tienda Blanes (bruto − costes operativos)

## Técnicas utilizadas

- CTEs anidadas y encadenadas (hasta 3 niveles) para pasar de datos crudos a un cuadrante de diagnóstico
- Pivoteo de filas a columnas con `MAX(CASE WHEN periodo = ... THEN ... END)`
- Lógica condicional de negocio (`CASE`) para traducir dos métricas numéricas en un diagnóstico cualitativo
- Comparativas YoY con rangos de fecha explícitos

## Resumen ejecutivo — respuesta a "¿estamos realmente mejorando?"

1. **El crecimiento agregado es real pero desigual:** la facturación total sube ~+2 % interanual, arrastrada por Barcelona Centro, pero 5 de las 10 tiendas están en realidad cayendo. "Las ventas crecen" es cierto a nivel de compañía y falso a nivel de la mitad de la red.
2. **No todo crecimiento es bueno:** Tienda Blanes crece un 24,6 % en ventas pero ha necesitado multiplicar por 2,6 su inversión en marketing, y su margen % ha bajado 3,3 puntos. Ese crecimiento no es gratis.
3. **No toda caída es mala:** Tienda Online factura un 8,2 % menos, pero gana más dinero neto que el año pasado gracias a subir precios y recortar descuentos.
4. **Madrid Centro es la urgencia real:** cae un 47,77 % en ventas y pierde margen al mismo tiempo — la única tienda en "deterioro" puro, sin ninguna métrica que compense a la otra.
5. **Recomendación:** sustituir el KPI único de "facturación" por un cuadro de mando de al menos dos ejes (ventas + margen), evitando confundir crecimiento de ingresos con creación de valor.

## Archivo

[`Ejercicio_SQL_3_Rendimiento.sql`](./Ejercicio_SQL_3_Rendimiento.sql)
