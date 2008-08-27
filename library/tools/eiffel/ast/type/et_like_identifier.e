indexing

	description:

		"Eiffel 'like identifier' or 'like *.identifier' types"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_LIKE_IDENTIFIER

inherit

	ET_LIKE_TYPE

feature -- Access

	name: ET_FEATURE_NAME is
			-- Name of the feature associated with current type
		deferred
		ensure
			name_not_void: Result /= Void
		end

	seed: INTEGER is
			-- Feature ID of one of the seeds of the
			-- feature associated with current type;
			-- 0 if not resolved yet
		deferred
		ensure
			seed_not_negative: Result >= 0
		end

end
