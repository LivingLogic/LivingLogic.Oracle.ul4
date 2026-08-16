# Changes

## 0.1 (2026-08-16)

Changed `mod_color_color(integer, integer)` to use unbounded `number`s and round
them when calculating the final integer values, since this seems to be what
browsers do for the CSS color blending algorithm.
