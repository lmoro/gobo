indexing

	description:

		"Dispenser containers"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 1999-2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class DS_DISPENSER [G]

inherit

	DS_EXTENDIBLE [G]
		redefine
			put, force,
			extend, append
		end

feature -- Access

	item: G is
			-- Item accessible from dispenser
		require
			not_empty: not is_empty
		deferred
		end

feature -- Element change

	put (v: G) is
			-- Add `v' to dispenser.
		deferred
		ensure then
			one_more: count = old count + 1
		end

	force (v: G) is
			-- Add `v' to dispenser.
		deferred
		ensure then
			one_more: count = old count + 1
		end

	extend (other: DS_LINEAR [G]) is
			-- Add items of `other' to dispenser.
			-- Add `other.first' first, etc.
		deferred
		ensure then
			new_count: count = old count + other.count
		end

	append (other: DS_LINEAR [G]) is
			-- Add items of `other' to dispenser.
			-- Add `other.first' first, etc.
		deferred
		ensure then
			new_count: count = old count + other.count
		end

feature -- Removal

	remove is
			-- Remove item from dispenser.
		require
			not_empty: not is_empty
		deferred
		ensure
			one_less: count = old count - 1
		end

	prune (n: INTEGER) is
			-- Remove `n' items from dispenser.
		require
			valid_n: 0 <= n and n <= count
		deferred
		ensure
			new_count: count = old count - n
		end

	keep (n: INTEGER) is
			-- Keep `n' items in dispenser.
		require
			valid_n: 0 <= n and n <= count
		deferred
		ensure
			new_count: count = n
		end

end -- class DS_DISPENSER
