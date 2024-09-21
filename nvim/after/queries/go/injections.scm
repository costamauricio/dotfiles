; extends

(
 (raw_string_literal) @injection.content
 	(#match? @injection.content ".*(SELECT|INSERT|UPDATE|DELETE)")
	(#offset! @injection.content 0 1 0 -1)
	(#set! injection.language "sql")
)
