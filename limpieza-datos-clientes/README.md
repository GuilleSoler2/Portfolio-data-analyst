# Limpieza de Datos — Tabla de Clientes

Limpieza y validación de una tabla de 4.870 clientes con errores típicos de un sistema sin validaciones: nombres inconsistentes, emails y teléfonos rotos, edades y fechas imposibles, y un número significativo de posibles duplicados.

## Principio seguido en todo el proceso

**No se elimina ni se fusiona ningún registro de forma automática.** Cuando un valor no se pudo validar con seguridad (email, teléfono, edad, fecha), se marcó con una columna de validez (Sí/No) en lugar de corregirlo a ciegas o borrarlo. Cuando dos filas podían ser el mismo cliente, se documentó el razonamiento y se dejó marcado para revisión humana, no fusionado por decisión propia del script.

## Problemas detectados y tratamiento

| Problema | Casos | % dataset | Tratamiento |
|---|---|---|---|
| Emails con formato inválido | 165 | 3,4 % | Marcado inválido — revisión manual |
| Emails nulos | 97 | 2,0 % | Se mantiene vacío — no se inventa |
| Teléfonos con formato inconsistente | 92 | 1,9 % | No se pudo estandarizar con seguridad |
| Teléfonos nulos | 146 | 3,0 % | Se mantiene vacío — no se inventa |
| Edades imposibles (negativas, >119, texto) | 71 | 1,5 % | Marcada inválida — revisión manual |
| Edades nulas | 73 | 1,5 % | Se mantiene vacío — no se inventa |
| Ciudades con variantes de escritura | 30 → 10 ciudades | — | Normalizadas (sin ambigüedad de identidad) |
| Fecha de nacimiento con formato inválido | 571 | 11,7 % | Marcada inválida — revisión manual |
| Fecha de nacimiento futura o imposible | 488 | 10,0 % | Marcada inválida — revisión manual |
| Nacimiento posterior a fecha de alta | 488 | 10,0 % | Marcada inválida — revisión manual |
| Filas en algún grupo de posible duplicado | 791 | 16,2 % | Ninguna eliminada — clasificadas por confianza |

## El problema central: detección de duplicados por nivel de confianza

En vez de una regla única "duplicado sí/no", cada posible coincidencia se clasificó según qué combinación de datos coincide entre dos filas — a más datos independientes coincidiendo, mayor la confianza:

| Nivel | Grupos | Criterio | Acción recomendada |
|---|---|---|---|
| **Alta** | 116 | Mismo nombre + mismo email | Fusionar — casi seguro es la misma persona |
| **Media** | 135 | Mismo email o mismo teléfono, con algún otro dato distinto | Revisar manualmente antes de fusionar |
| **Baja** | 145 | Solo coincide el nombre, o solo el teléfono | Probablemente NO es duplicado — mantener separado |

**Ejemplo real (confianza Alta):** dos filas distintas para "Abigaíl Sáenz-sosa" / "ABIGAÍL SÁENZ-SOSA" comparten exactamente el mismo email — mismo cliente dado de alta dos veces.

**Ejemplo real (confianza Baja, NO tratado como duplicado):** dos clientes con el mismo nombre pero teléfono, email y ciudad completamente distintos — casi con seguridad dos personas diferentes.

## Decisiones clave

- **Nombres:** se normalizó la escritura solo para poder comparar (columna auxiliar interna), pero el nombre nunca se usó por sí solo como prueba de duplicado — siempre se combinó con email o teléfono.
- **Emails y teléfonos inválidos:** nunca se corrigió adivinando el dato correcto (ej. no se asumió a qué dominio le faltaba la arroba), porque inventar un carácter podría enviar la comunicación a la persona equivocada.
- **Edad:** no se recalculó desde la fecha de nacimiento de forma automática, porque esa columna también tenía errores — arrastrar un error de una columna a otra habría producido un dato "corregido" igual de falso.
- **Ciudades:** al ser una lista cerrada de 10 valores conocidos, sí se normalizó automáticamente (sin ambigüedad de identidad, a diferencia del nombre).

## Balance final

| Indicador | Valor |
|---|---|
| Clientes en la tabla original | 4.870 |
| Filas eliminadas | 0 |
| Filas en algún grupo de posible duplicado | 791 (16,2 %) |
| Grupos de posible duplicado | 396 (116 alta / 135 media / 145 baja) |

## Recomendación

Antes de fusionar cualquier grupo de confianza Alta o Media, confirmar mínimamente (contactar al cliente o revisar historial de pedidos) para no perder historial o consentimientos asociados a un ID. A futuro: validar email y teléfono en el alta, y usar el email como clave única para evitar registros repetidos.

## Archivos

- [`1_Clientes_Original_Sucio.xlsx`](./1_Clientes_Original_Sucio.xlsx) — dataset original sin tratar
- [`2_Clientes_Limpio_Con_Validaciones.xlsx`](./2_Clientes_Limpio_Con_Validaciones.xlsx) — dataset limpio con columnas de validación
