indexing

	description:

		"Total order comparators"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class DS_COMPARATOR [G]

inherit

	DS_PART_COMPARATOR [G]

feature -- Status report

	order_equal (u, v: G): BOOLEAN is
			-- Are `u' and `v' considered equal?
		require
			u_not_void: u /= Void
			v_not_void: v /= Void
		do
			Result := not less_than (u, v) and not less_than (v, u)
		ensure
			definition: Result = (not less_than (u, v) and not greater_than (u, v))
		end

	less_equal (u, v: G): BOOLEAN is
			-- Is `u' considered less than or equal to `v'?
		require
			u_not_void: u /= Void
			v_not_void: v /= Void
		do
			Result := not less_than (v, u)
		ensure
			definition: Result = (less_than (u, v) or order_equal (u, v))
		end

	greater_equal (u, v: G): BOOLEAN is
			-- Is `u' considered greater than or equal to `v'?
		require
			u_not_void: u /= Void
			v_not_void: v /= Void
		do
			Result := not less_than (u, v)
		ensure
			definition: Result = (greater_than (u, v) or order_equal (u, v))
		end

end -- class DS_COMPARATOR
