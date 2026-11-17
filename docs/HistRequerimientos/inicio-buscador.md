# Requerimientos — Buscador del Inicio

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"06 · Inicio · Sin canchas"**, bloque **"Buscador"** ( el buscador existe en vectores dentro de ese frame; mismo campo en la pantalla 01 )
- `docs/prototipos/01 · Inicio.png` ( referencia estática )

---

## 1. Objetivo

Implementar el **buscador de la pantalla Inicio** de la app Flutter
(`src/FrontEnd/`): el campo `Buscá canchas cerca tuyo...` bajo el header. Es
la **parte 3 de la pantalla 01 · Inicio** ( parte 1: navegación; parte 2:
header — ambas implementadas ).

Por esta etapa el campo **acepta texto pero no filtra nada**: el filtrado
llega con la lista de canchas ( parte 5 ).

## 2. Contexto

- La pantalla Inicio ya tiene su header ( RD `../HistRequerimientos/inicio-header.md` )
  y la estructura de contenido del mockup: columna con hueco **16** entre
  bloques. El buscador es el segundo bloque.
- El campo sigue el patrón de los inputs del login ( `login.md` §4 ) pero con
  las medidas propias del mockup ( §4 ): sin label encima, ícono a la
  izquierda, placeholder como hint.
- Tokens existentes. Sin dependencias nuevas.

## 3. Alcance

### Dentro del alcance

- Campo Buscador bajo el header ( §4 ), **editable** ( acepta texto del
  usuario ).
- Teclado del sistema con acción "search" ( sin efecto por ahora ).

### Fuera de alcance

- Filtrado de canchas ( llega con la lista — parte 5 ).
- Sugerencias, historial, autocompletado, botón de limpiar.
- Búsqueda por voz / por ubicación.

## 4. Espec visual ( bloque "Buscador" del mockup )

Segundo bloque de la columna del Inicio ( hueco 16 bajo el header ):

| Propiedad | Valor |
|---|---|
| Campo | ancho completo, fondo `$surface`, borde `$border` 1px, radio 12 |
| Padding interno | 13 vertical / 14 horizontal |
| Contenido | fila ( hueco 10, centrada ): ícono `search` (lucide) 18×18 `$text-2` + placeholder |
| Placeholder | `Buscá canchas cerca tuyo...` — 14px, normal, `$text-2` |
| Texto ingresado | 14px, `$text` ( mismo tamaño que el placeholder ) |

## 5. Requerimientos funcionales

### RF-01 — Campo de búsqueda

- El campo es un `TextField` editable: al tocarlo abre el teclado y acepta
  texto; al soltar el foco se conserva lo escrito.
- Teclado de texto con acción "search" ( `TextInputAction.search` ) **sin
  efecto**: no filtra ni navega ( RF-02 ).
- Tocar fuera del campo descarta el teclado, sin alterar el valor.

### RF-02 — Sin funcionalidad de filtrado ( por esta etapa )

- Escribir no cambia lo que se muestra en la pantalla ( no hay lista todavía
  y este RD no filtra ).
- El valor escrito se conserva en el campo mientras la app está abierta
  ( estado local de la pantalla ).

## 6. Requerimientos no funcionales

- **Idioma:** placeholder exacto `Buscá canchas cerca tuyo...` (`es-AR`).
- **Tipografía:** Inter ( o la fuente por defecto de Flutter si Inter no está
  configurada aún — misma decisión que las etapas previas ).
- **Tokens:** `$surface`, `$border`, `$text-2`, `$text` — todos existentes.
- **Ícono:** `LucideIcons.search` ( ya instalado ).
- **Plataforma:** móvil, viewport 375×844; se adapta sin romperse.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Bajo el header del Inicio, con hueco 16, aparece el campo del §4 ( fondo
   blanco, borde gris, radio 12 ) con la lupa gris a la izquierda y el
   placeholder `Buscá canchas cerca tuyo...`.
2. Tocar el campo abre el teclado; escribir muestra el texto en `$text` 14px
   en lugar del placeholder.
3. Tocar fuera descarta el teclado y el texto escrito se conserva.
4. La acción "search" del teclado no produce ningún cambio visible.
5. El resto de la pantalla ( header, tab bar, otros tabs ) no cambia.
6. Sin overflow en 375×844 ni en pantallas chicas.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Interactividad | Campo **editable** real ( no solo decorativo ) pero sin filtrar — el filtrado llega con la lista ( parte 5 ) |
| Acción "search" del teclado | Sin efecto por ahora ( RF-02 ) |
| Estado del texto | Local de la pantalla, se conserva al perder foco; no se comparte todavía ( el estado común llega con el filtrado ) |
| Botón de limpiar | No ( el mockup no lo dibuja ) |
| Tipografía | Fuente por defecto si Inter no está configurada ( misma decisión que las etapas previas ) |

## 9. Riesgos y notas para la siguiente iteración

- Con la lista de canchas ( parte 5 ) este campo pasa a filtrar: su estado
  sube a la pantalla Inicio y el texto se convierte en criterio de búsqueda.
- Si en el futuro hay sugerencias/historial, este RD no las define: sería un
  RD propio.
