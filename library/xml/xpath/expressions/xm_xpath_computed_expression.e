indexing

	description:

		"XPath Expressions, other than values"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_COMPUTED_EXPRESSION

	-- There are two principal routines for evaluating an expression:
	--  `iterator', which yields an iterator over the result of the expression
	--  as a sequence, and `evaluate_item', which sets an XM_XPATH_ITEM.
	-- Both routines take an XM_XPATH_CONTEXT object to supply the evaluation context;
	--  for an expression that is a Value, this argument is ignored and may be `Void'.
	-- This base class provides an implementation of iterator in terms of evaluate_item
	--  that works only for singleton expressions, and an implementation
	--  of evaluate_item in terms of iterator that works only for non-singleton expressions.
	-- Sub-classes of expression must therefore provide either iterator or evaluate_item:
	--  they do not have to provide both.

inherit

	XM_XPATH_EXPRESSION

	XM_XPATH_EXPRESSION_CONTAINER

feature {NONE} -- Initialization

	initialize is
			-- Initialize attributes.
			-- All creation routines should call this
		do
			line_number := -1
		end

feature -- Access

	line_number: INTEGER
			-- Line number of the expression

	sub_expressions: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION] is
			-- Immediate sub-expressions of `Current'
		do

			-- Default implementation returns an empty list;
			-- Suitable for an expression without sub-expressions.
			
			create Result.make_default
			Result.set_equality_tester (expression_tester)
		end
	
	container: XM_XPATH_EXPRESSION_CONTAINER is
			-- Containing parent
		do
			Result := parent
		end

	parameter_references (a_binding: XM_XPATH_BINDING): INTEGER is
			-- Approximate count of references by parameters of `Current' to `a_binding'
		do
			-- pre-condition cannot be met
		end

	is_repeated_sub_expression (a_child: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Is `a_child' a repeatedly-evaluated sub-expression?
		require
			child_not_void: a_child /= Void
		do
			Result := False -- default implementation
		end

feature -- Comparison

	same_expression (other: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Are `Current' and `other' the same expression?
		do
			Result := Current = other
		end

feature -- Status report
	
	frozen is_computed_expression: BOOLEAN is
			-- Is `Current' a computed expression?
		do
			Result := True
		end

	frozen is_user_function: BOOLEAN is
			-- Is `Current' a compiled user function?
		do
			-- `False'
		end

feature -- Status setting

	frozen compute_static_properties is
			-- Compute the static properties
		require
			not_yet_computed: not are_static_properties_computed
		do
			if not are_dependencies_computed then compute_dependencies end
			if not are_cardinalities_computed then compute_cardinality end
			if not are_special_properties_computed then compute_special_properties end
		ensure
			computed: are_static_properties_computed
			dependencies_not_void: dependencies /= Void
			intrisic_dependencies_not_void: intrinsic_dependencies /= Void
			cardinalities_not_void: cardinalities /= Void
			special_properties_not_void: special_properties /= Void
		end


	compute_intrinsic_dependencies is
			-- Determine the intrinsic dependencies of an expression.
		require	not_yet_computed: not are_intrinsic_dependencies_computed
		do
			initialize_intrinsic_dependencies
		ensure
			computed: are_intrinsic_dependencies_computed and then intrinsic_dependencies /= Void
		end
			
	compute_dependencies is
			-- Compute dependencies on context.
			-- This default implementation computes them as
			-- the union of the sub-expressions' dependencies.
		require
			not_yet_computed: not are_dependencies_computed
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			if not are_intrinsic_dependencies_computed then compute_intrinsic_dependencies end
			dependencies := clone (intrinsic_dependencies)
			are_dependencies_computed := True
			from
				a_cursor := sub_expressions.new_cursor
				a_cursor.start
			variant
				sub_expressions.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				merge_dependencies (a_cursor.item.dependencies)
				a_cursor.forth
			end			
		ensure
			intrinsic_computed: are_intrinsic_dependencies_computed and then intrinsic_dependencies /= Void
			computed: are_dependencies_computed and then dependencies /= Void
		end

	reset_static_properties is
			-- Re-compute all static properties.
		require
			static_properties_previously_computed: are_static_properties_computed
		do
			are_dependencies_computed := False
			are_intrinsic_dependencies_computed := False
			are_cardinalities_computed := False
			are_special_properties_computed := False
			compute_static_properties
		end

feature -- Optimization

	simplify is
			-- Preform context-independent static optimizations
		do
			-- do_nothing
		end

	promote (an_offer: XM_XPATH_PROMOTION_OFFER) is
			-- Promote this subexpression.
		do
			do_nothing
		end
	
feature -- Evaluation

	effective_boolean_value (a_context: XM_XPATH_CONTEXT): XM_XPATH_BOOLEAN_VALUE is
			-- Effective boolean value
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			an_item: XM_XPATH_ITEM
			a_node: XM_XPATH_NODE
			a_boolean: XM_XPATH_BOOLEAN_VALUE
			a_string: XM_XPATH_STRING_VALUE
			a_number: XM_XPATH_NUMERIC_VALUE
		do
			an_iterator := iterator (a_context)
			if not an_iterator.is_error then
				an_iterator.start
				if not an_iterator.after then
					an_item := an_iterator.item
					a_node ?= an_item
					if a_node /= Void then
						create Result.make (True)
					else
						a_boolean ?= an_item
						if a_boolean /= Void then
							an_iterator.forth
							if an_iterator.after then
								create Result.make (a_boolean.value)
							else
								Result := effective_boolean_value_in_error ("sequence of two or more items starting with an atomic value")
							end
						else
							a_string ?= an_item
							if a_string /= Void then
								an_iterator.forth
								if an_iterator.after then
									create Result.make (a_string.string_value.count /= 0)
								else
									Result := effective_boolean_value_in_error ("sequence of two or more items starting with an atomic value")
								end
							else
								a_number ?= an_item
								if a_number /= Void then
									an_iterator.forth
									if an_iterator.after then
										Result := a_number.effective_boolean_value (a_context)
									else
										Result := effective_boolean_value_in_error ("sequence of two or more items starting with an atomic value")
									end
								else
									Result := effective_boolean_value_in_error ("sequence starting with an atomic value other than a boolean, number, or string")
								end
							end
						end
					end
				end
				if Result = Void then create Result.make (False) end			
			else
				create Result.make (False)
				Result.set_last_error (an_iterator.error_value)
			end
		end

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		local
			an_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
		do
			last_evaluated_item := Void
			an_iterator := iterator (a_context)
			if an_iterator.is_error then
				create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make (an_iterator.error_value)
			else
				an_iterator.start
				if an_iterator.is_error then
					create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make (an_iterator.error_value)
				elseif an_iterator.after then
					last_evaluated_item := Void -- Empty sequence
				else
					last_evaluated_item := an_iterator.item
				end
			end
		end

	evaluate_as_string (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a String
		local
			a_string: XM_XPATH_STRING_VALUE
		do
			evaluate_item (a_context)
			if last_evaluated_item = Void then
				create last_evaluated_string.make ("")
			elseif last_evaluated_item.is_error then
				todo ("Logic error in {XM_XPATH_COMPUTED_EXPRESSION}.evaluate_as_string", True)
			else
				a_string ?= last_evaluated_item
				if a_string = Void then
					create last_evaluated_string.make ("")
				else
					last_evaluated_string := a_string
				end
			end
		end

	iterator (a_context: XM_XPATH_CONTEXT): XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM] is
			-- Iterator over the values of a sequence
		do
			
			-- The value of every expression can be regarded as a sequence, s
			--  so this routine is supported for all expressions.
			-- This default implementation handles iteration for expressions that
			--  return singleton values: for non-singleton expressions, the subclass must
			--  provide its own implementation.
				check
					singleton_expression: not cardinality_allows_many
					-- Not a prefect check, as cardinality may not have been set!
				end
			evaluate_item (a_context)
			if last_evaluated_item = Void then
				create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} Result.make
			elseif last_evaluated_item.is_error then
				create {XM_XPATH_INVALID_ITERATOR} Result.make (last_evaluated_item.error_value) 
			else
				create {XM_XPATH_SINGLETON_ITERATOR [XM_XPATH_ITEM]} Result.make (last_evaluated_item) 
			end
		end

feature -- Element change

	set_line_number (a_line_number: INTEGER) is
			-- Set line number to `a_line_number'.
		require
			strictly_positive_line_number: a_line_number > 0
		do
			line_number := a_line_number
		ensure
			set: line_number = a_line_number
		end

	set_parent (a_container: XM_XPATH_EXPRESSION_CONTAINER) is
			-- Set `a_container' to be parent of `Current'.
		require
			not_self: a_container /= Current
		do
			parent := a_container
		ensure
			parent_set: parent = a_container
		end

	adopt_child_expression (a_child: XM_XPATH_EXPRESSION) is
			-- Adopt `a_child' if it is a computed expression.
		require
			child_expression_not_void: a_child /= Void
			not_self: a_child /= Current
		local
			a_computed_expression: XM_XPATH_COMPUTED_EXPRESSION
		do
			a_computed_expression ?= a_child
			if a_computed_expression /= Void then
				if parent = Void and then a_computed_expression.container /= Current then
					parent := a_computed_expression.container
				end
				a_computed_expression.set_parent (Current)
				-- TODO copy location information
			end
		end
	
feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		require
			not_yet_computed: not are_cardinalities_computed			
		deferred
		ensure
			computed: are_cardinalities_computed and then cardinalities /= Void
		end

	compute_special_properties is
			-- Compute special properties.
		require
			not_yet_computed: not are_special_properties_computed			
		do
			initialize_special_properties
		ensure
			computed: are_special_properties_computed and then special_properties /= Void
		end

feature {NONE} -- Implementation
	
	parent: XM_XPATH_EXPRESSION_CONTAINER
			-- Containing parent

	effective_boolean_value_in_error (a_reason: STRING): XM_XPATH_BOOLEAN_VALUE is
			-- Type error for `effective_boolean_value'
		require
			reason_not_empty: a_reason /= Void and then a_reason.count > 0
		do
			create Result.make (False)
			Result.set_last_error_from_string ("Effective boolean value is not defined for a " + a_reason, Gexslt_eiffel_type_uri, "EFFECTIVE_BOOLEAN_VALUE", Type_error)
		end

end
	
