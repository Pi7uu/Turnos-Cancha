# Spec — Buscador del Inicio

> As-built de `docs/HistRequerimientos/inicio-buscador.md` ( RD 2026-11-17 ).
> Parte 3 de la pantalla 01 · Inicio.

## Propósito

El campo de búsqueda de la pantalla Inicio ( `Buscá canchas cerca tuyo...` ):
acepta texto del usuario pero **no filtra todavía** — el filtrado llega con
la lista de canchas.

## Cómo funciona

- Segundo bloque de la columna del Inicio ( `inicio-header.md` define la
  estructura: padding 8/16/16/16, hueco 16 entre bloques ). Va con
  `SizedBox(height: 16)` debajo del header.
- **Campo** ( `_Buscador` en `lib/features/inicio/inicio_screen.dart` ):
  `TextField` editable, fondo `$surface`, borde `$border` 1px (todos los
  estados), radio 12, padding interno 13 vertical / 14 horizontal. Lupa
  `LucideIcons.search` 18×18 `$text-2` a la izquierda, placeholder
  `Buscá canchas cerca tuyo...` 14px normal `$text-2`; texto ingresado 14px
  `$text`.
- **Geometría medida por tests**: ícono a 14px del borde, hueco 10 ícono →
  texto. Ojo de implementación: el decorador de Flutter pega el `prefixIcon`
  al borde y coloca el texto a `anchoDelPrefix + 4`, así que el hueco se
  logra con un prefix de 38 ( 14 + 18 + 6 ) — no con el padding del mockup
  literal ( ver §Decisiones ).
- **Interacción**: tap abre el teclado y se puede escribir ( `keyboardType:
  text` ); la acción **"search" del teclado no hace nada** ( sin `onSubmitted`
  ); tap fuera descarta el teclado ( `GestureDetector` + `unfocus` sobre el
  body ) y **el texto se conserva**. El valor vive en un
  `TextEditingController` del estado de `InicioScreen`.
- El hint permanece en el árbol de widgets fadeado al escribir ( comportamiento
  estándar de Flutter ); lo que desaparece es su superficie visible.

## Archivos

- `lib/features/inicio/inicio_screen.dart` — `_Buscador` + el controller en
  `_InicioScreenState` ( InicioScreen pasó a StatefulWidget por esto ).
- `test/inicio_buscador_test.dart` ( 6 tests: presencia, hueco 16, estilo y
  geometría, texto conservado, teclado search inerte, sin overflow ).

## Decisiones

- Campo **editable** pero sin filtrar ( no era solo decorativo: un campo
  tipeable es la base para el filtrado de la parte 5 ).
- Estado del texto local de la pantalla; al llegar el filtrado sube al estado
  del Inicio compartido.
- Sin botón de limpiar ni sugerencias ( el mockup no los dibuja ).
- Padding literal 13/14 en `contentPadding`; el hueco 10 se logra con el
  prefix de 38px ( la fórmula del decorador de Flutter no replica el padding
  del frame de pen ).

## Límites ( NO hace )

- **No filtra** nada: escribir no cambia lo que se muestra.
- Sin sugerencias, historial, autocompletado ni botón de limpiar.
- La acción "search" del teclado está inerte.

## Conexiones

- Vive bajo el **header del Inicio** ( `inicio-header.md` ) en la misma
  columna; bloquea nada hasta la parte 5 ( lista de canchas ), cuando su
  texto se convierte en criterio de búsqueda.
