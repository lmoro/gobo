indexing

	description:

		"XSLT patterns that matches no node at all"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_NO_NODE_TEST

inherit

	XM_XSLT_NODE_TEST
		redefine
			default_priority, matches
		end
	
	XM_XPATH_NO_NODE_TEST

creation

	make

feature -- Access

		frozen default_priority: DOUBLE is
			--  Determine the default priority to use if this pattern appears as a match pattern for a template with no explicit priority attribute.
		do
			Result := -0.5
		end

feature -- Matching

	frozen matches (a_node: XM_XPATH_NODE;  a_transformer: XM_XSLT_TRANSFORMER): BOOLEAN is
			-- Determine whether this Pattern matches the given Node;
		do
			Result := False
		end

end
	