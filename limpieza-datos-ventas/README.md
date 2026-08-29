# Limpieza de Datos — Dataset de Ventas (Sistema Antiguo)

Limpieza de un dataset de 20.000 ventas procedentes de un sistema antiguo sin validaciones: duplicados exactos, IDs repetidos, nulos, fechas y precios en formatos heterogéneos, categorías sin normalizar y valores negativos sin contexto.

## Regla general seguida en todo el proceso

**Nunca inventar un dato que no está.** Cuando un valor no se pudo recuperar con confianza (fecha, producto o precio irrecuperables, o valores negativos sin contexto), la fila se separó a un archivo de revisión en vez de eliminarla en silencio o rellenarla con un valor supuesto.

## Problemas detectados y tratamiento

| Problema | Casos | % dataset | Tratamiento |
|---|---|---|---|
| Duplicados exactos (misma venta repetida) | 480 | 2,4 % | Eliminados |
| IDs de venta duplicados con contenido distinto | 319 IDs / 639 filas | 3,2 % | ID renumerado, original conservado |
| Nulos — Fecha de venta | 1.186 | 5,9 % | Reparado si el formato era válido |
| Nulos — Cliente | 396 | 2,0 % | Rellenado: "Cliente no especificado" |
| Nulos — Ciudad | 297 | 1,5 % | Rellenado: "Ciudad no especificada" |
| Nulos — Producto | 231 | 1,2 % | Excluido si no recuperable |
| Nulos — Precio unitario | 391 | 2,0 % | Excluido si no recuperable |
| Nulos — Método de pago | 595 | 3,0 % | Rellenado: "No especificado" |
| Fechas en formato inválido / texto sin sentido | 2.170 | 10,9 % | Excluidas — revisión manual |
| Fechas futuras o imposibles | 1.149 | 5,7 % | Excluidas — revisión manual |
| Categorías con variantes de escritura | 15 → 5 categorías | — | Normalizadas al catálogo oficial |
| Ciudades con variantes de escritura | 30 → 10 ciudades | — | Normalizadas al catálogo oficial |
| Espacios innecesarios en texto | 22.791 valores | — | Recortados y colapsados |
| Precios almacenados como texto | 16.714 | 83,6 % | Convertidos a tipo numérico |
| Precios no interpretables | 30 | 0,2 % | Excluidos — revisión manual |
| Importe total inconsistente con Cantidad × Precio | 1.520 | 7,6 % | Recalculado automáticamente |
| Valores negativos (cantidad o precio) | 228 (172 tras deduplicar) | 1,1 % | Excluidos — revisión manual |
| Productos fuera de catálogo | 185 (181 tras deduplicar) | 0,9 % | Excluidos — revisión manual |

## Decisiones clave

- **Duplicados:** se consideró duplicado real solo cuando *todos* los campos relevantes coincidían tras la limpieza de texto. No se usó el ID de venta como criterio, porque el ID del sistema antiguo demostró no ser fiable (ver IDs duplicados).
- **Fechas:** se probaron los 4 formatos válidos detectados; una fecha futura o con mes/día imposible se consideró no fiable y no se intentó "adivinar" — se separó para revisión.
- **Precios:** se construyó un parser que detecta el separador decimal correcto según el patrón (miles con coma, coma decimal, o punto decimal) antes de convertir a número estándar.
- **Importe total:** no se confió en el valor guardado — se recalculó siempre como Cantidad × Precio ya limpios, porque es un campo derivado que no debería introducir información nueva.
- **Negativos:** al no existir un campo de "tipo de movimiento" que justifique un signo negativo, no se asumió que fueran devoluciones — se separaron para que el equipo comercial confirme caso por caso.
- **IDs duplicados:** se generó un nuevo identificador secuencial propio (`ID_Venta_Limpio`), conservando el original en una columna aparte para trazabilidad.

## Balance final

| Indicador | Valor |
|---|---|
| Filas en el dataset original | 20.000 |
| Duplicados exactos eliminados | 480 |
| Filas movidas a revisión manual | 4.999 |
| Filas en el dataset limpio final | 14.521 |
| % de filas conservadas | 72,6 % |

El 27,4 % restante no se ha perdido: está disponible íntegro en un archivo de revisión para que el equipo de negocio decida caso por caso.

## Recomendación

Para evitar que estos problemas se repitan: (1) validar formato de fecha y precio en el punto de entrada, no después; (2) usar listas desplegables cerradas para Ciudad, Categoría y Método de pago en vez de texto libre; (3) generar el ID de venta automáticamente en la base de datos; (4) añadir un campo explícito de "tipo de movimiento" (venta/devolución) para que un valor negativo sea intencional, no un error de digitación.

## Archivos

- [`1_Dataset_Original_Sucio.xlsx`](./1_Dataset_Original_Sucio.xlsx) — dataset original sin tratar
- [`2_Dataset_Limpio.xlsx`](./2_Dataset_Limpio.xlsx) — dataset limpio final
