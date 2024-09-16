; extends

(
 (raw_string_literal) @sql (#match? @sql ".*(SELECT|INSERT|UPDATE|DELETE)")
)
