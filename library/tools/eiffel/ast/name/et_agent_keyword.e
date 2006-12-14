indexing

	description:

		"Eiffel 'agent' keywords"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2006, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_AGENT_KEYWORD

inherit

	ET_KEYWORD
		rename
			make_agent as make,
			text as name
		redefine
			process, is_equal
		end

	ET_FEATURE_NAME
		undefine
			first_position, last_position,
			is_equal, is_precursor, is_local,
			is_infix, is_prefix, is_alias
		end

create

	make

feature -- Access

	lower_name: STRING is
			-- Lower-name of feature name
			-- (May return the same object as `name' if already in lower case.)
		do
			Result := tokens.agent_keyword_name
		end

	hash_code: INTEGER is
			-- Hash code
		do
			Result := code.code
		end

feature -- Comparison

	same_call_name (other: ET_CALL_NAME): BOOLEAN is
			-- Are `Current' and `other' the same feature call name?
			-- (case insensitive)
		do
			Result := ANY_.same_types (Current, other)
		end

	same_feature_name (other: ET_FEATURE_NAME): BOOLEAN is
			-- Are feature name and `other' the same feature name?
			-- (case insensitive)
		do
			Result := ANY_.same_types (Current, other)
		end

	is_equal (other: like Current): BOOLEAN is
			-- Are current 'agent' keyword and `other' considered equal?
		do
			Result := ANY_.same_types (Current, other)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_agent_keyword (Current)
		end

end
