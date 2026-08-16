# Changes

## 0.3 (2026-08-16)

Added the missing functions `contains_clob_str(clob, varchar2)` and
`contains_clob_clob(clob, clob)`. The vSQL rules for `CLOB in STR`,
`CLOB in CLOB`, `CLOB not in STR` and `CLOB not in CLOB` generate calls
to them, so those expressions failed with `ORA-00904`.


## 0.2 (2026-08-16)

Added the missing function `bool_nulllist(integer)`. The vSQL rules for
`not NULLLIST` and `bool(NULLLIST)` generate calls to it, so those expressions
failed with `ORA-00904`.


## 0.1 (2026-08-16)

Changed `mod_color_color(integer, integer)` to use unbounded `number`s and round
them when calculating the final integer values, since this seems to be what
browsers do for the CSS color blending algorithm.
