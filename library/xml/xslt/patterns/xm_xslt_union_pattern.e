indexing

	description:

		"XSLT union patterns"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_UNION_PATTERN

inherit

	XM_XSLT_PATTERN
		redefine
			simplified_pattern, type_check, set_original_text
		end

creation

	make

feature {NONE} -- Initialization

	make (a_pattern_one, a_pattern_two: XM_XSLT_PATTERN) is
			-- Establish invariant.
		require
				pattern_one_not_void: a_pattern_one /= Void
				pattern_two_not_void: a_pattern_two /= Void
		do
			left_hand_side := a_pattern_one
			right_hand_side := a_pattern_two
			if a_pattern_one.node_kind = a_pattern_two.node_kind then
				node_type := a_pattern_one.node_kind
			else
				node_type := Any_node
			end
		ensure
				pattern_one_set: left_hand_side = a_pattern_one
				pattern_two_set: right_hand_side = a_pattern_two
		end

feature -- Access

	node_test: XM_XSLT_NODE_TEST is
			-- Retrieve an `XM_XSLT_NODE_TEST' that all nodes matching this pattern must satisfy
		do
			if node_type = Any_node then
				create {XM_XSLT_ANY_NODE_TEST} Result.make
			else
				create {XM_XSLT_NODE_KIND_TEST} Result.make (node_type)
			end
		end

feature -- Status setting

	set_original_text (a_text_string: STRING) is
			-- Set original text of the pattern.
		do
			original_text := clone (a_text_string)
			left_hand_side.set_original_text (a_text_string)
			right_hand_side.set_original_text (a_text_string)
		end

feature -- Analysis

	simplified_pattern: XM_XSLT_PATTERN is
			-- Simplify a pattern by applying any context-independent optimizations;
			-- Default implementation does nothing
		do
			create {XM_XSLT_UNION_PATTERN} Result.make (left_hand_side.simplified_pattern, right_hand_side.simplified_pattern)
		end

	type_check (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Type-check the pattern;
			-- Default implementation does nothing. This is only needed for patterns that contain
			-- variable references or function calls.
		do
			left_hand_side.type_check (a_context)
			right_hand_side.type_check (a_context)
		end

feature -- Matching

	matches (a_node: XM_XPATH_NODE; a_transformer: XM_XSLT_TRANSFORMER): BOOLEAN is
			-- Determine whether this Pattern matches the given Node;
		do
			Result := left_hand_side.matches (a_node, a_transformer) or else right_hand_side.matches (a_node, a_transformer)
		end

feature {NONE} -- Implementation

	left_hand_side, right_hand_side: XM_XSLT_PATTERN
			-- Patterns forming union

	node_type: INTEGER
			-- Type of nodes in this pattern

invariant

	pattern_one_not_void: left_hand_side /= Void
	pattern_two_not_void: right_hand_side /= Void

end
	
