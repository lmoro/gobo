indexing

	description:

		"Eiffel 'precursor' keywords"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_PRECURSOR_KEYWORD

inherit

	ET_KEYWORD
		rename
			make_precursor as make,
			text as name
		redefine
			process, is_equal
		end

	ET_FEATURE_NAME
		undefine
			is_equal, is_precursor, is_local,
			is_infix, is_prefix
		redefine
			precursor_keyword
		end

creation

	make

feature -- Access

	hash_code: INTEGER is
			-- Hash code
		do
			Result := code.code
		end

feature -- Comparison

	same_feature_name (other: ET_FEATURE_NAME): BOOLEAN is
			-- Are feature name and `other' the same feature name?
			-- (case insensitive)
		do
			Result := other.is_precursor
		end

	is_equal (other: like Current): BOOLEAN is
			-- Are current Precursor keyword and `other' considered equal?
		do
			Result := same_type (other)
		end

feature -- Conversion

	precursor_keyword: ET_PRECURSOR_KEYWORD is
			-- Current feature name viewed as a 'precursor' keyword
		do
			Result := Current
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_precursor_keyword (Current)
		end

end