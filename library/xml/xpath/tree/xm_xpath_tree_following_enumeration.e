indexing

	description:

		"Objects that enumerate the following:: Axis"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TREE_FOLLOWING_ENUMERATION
	
inherit

	XM_XPATH_AXIS_ITERATOR [XM_XPATH_TREE_NODE]
		redefine
			start
		end

	XM_XPATH_TREE_ENUMERATION

	XM_XPATH_TYPE

creation

	make
	
feature {NONE} -- Initialization

	make (a_starting_node: XM_XPATH_TREE_NODE; a_node_test: XM_XPATH_NODE_TEST) is
			-- Establish invariant
		require
			starting_node_not_void: a_starting_node /= Void
			node_test_not_void: a_node_test /= Void
		local
			a_node: like a_starting_node
		do
			make_enumeration (a_starting_node, a_node_test)
			root ?= starting_node.document_root
				check
					root_not_void: root /= Void
				end
			if a_starting_node.node_type = Attribute_node or else a_starting_node.node_type = Namespace_node then
				next_node := starting_node.parent.next_node_in_document_order (root)
			else
				from
					a_node := a_starting_node
				until
					next_node /= Void or else a_node = Void
				loop
					next_node ?= a_node.next_sibling
					if next_node = Void then
						a_node := a_node.parent
					end
				end
			end
			from
			until
				is_conforming (next_node)
			loop
				advance_one_step
			end

		ensure
			starting_node_set: starting_node = a_starting_node
			test_set: node_test = a_node_test
		end

feature -- Cursor movement

	start is
			-- Move to next position
		do
			index := 1
			current_item := next_node
		end

	forth is
			-- Move to next position
		do
			index := index + 1
			advance
			current_item := next_node
		end

feature -- Duplication

	another: like Current is
			-- Another iterator that iterates over the same items as the original;
			-- The new iterator will be repositioned at the start of the sequence
		do
			create Result.make (starting_node, node_test)
		end

feature {NONE} -- Implemnentation

	root: like starting_node

	advance_one_step is
			-- Move to the next candidate node
		do
			next_node := next_node.next_node_in_document_order (root)
		end

end
	