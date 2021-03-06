note
	description: "[
		Objects representing delayed calls to a procedure.
		with some operands possibly still open.
		]"
	library: "Free implementation of ELKS library"
	copyright: "Copyright (c) 1986-2004, Eiffel Software and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class
	PROCEDURE [BASE_TYPE, OPEN_ARGS -> TUPLE create default_create end]

inherit
	ROUTINE [BASE_TYPE, OPEN_ARGS]

feature -- Calls

	call (args: OPEN_ARGS)
			-- Call routine with operands `args'.
		external
			"built_in"
		end

end
