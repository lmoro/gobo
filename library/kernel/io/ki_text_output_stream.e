indexing

	description:

		"Interface for character output streams with the notion of lines"

	library:    "Gobo Eiffel Kernel Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 2001, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

deferred class KI_TEXT_OUTPUT_STREAM

inherit

	KI_CHARACTER_OUTPUT_STREAM

feature -- Output

	put_line (a_string: STRING) is
			-- Write `a_string' to output stream
			-- followed by a line separator.
		require
			is_writable: is_writable
			a_string_not_void: a_string /= Void
		do
			put_string (a_string)
			put_new_line
		end

	put_new_line is
			-- Write a line separator to output stream.
		require
			is_writable: is_writable
		do
			put_string (eol)
		end

feature -- Access

	eol: STRING is
			-- Line separator
		deferred
		ensure
			eol_not_void: Result /= Void
			eol_not_empty: Result.count > 0
		end

end -- class KI_TEXT_OUTPUT_STREAM
