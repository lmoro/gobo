indexing

	description:

		"Imported routines that ought to be in class STRING_BUFFER. %
		%A string buffer is a sequence of characters equipped with %
		%features `put', `item' and `count'."

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 1999, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class KL_IMPORTED_STRING_BUFFER_ROUTINES

obsolete

	"[020717] Use descendants of KI_CHARACTER_BUFFER instead."

feature -- Access

	STRING_BUFFER_: KL_STRING_BUFFER_ROUTINES is
			-- Routines that ought to be in class STRING_BUFFER
		once
			create Result
		ensure
			string_buffer_routines_not_void: Result /= Void
		end

feature -- Type anchors

	STRING_BUFFER_TYPE: STRING is do end
			-- Type anchor

end