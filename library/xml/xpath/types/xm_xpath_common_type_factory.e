indexing

	description:

		"Objects that create common built-in types"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_COMMON_TYPE_FACTORY

inherit

	XM_XPATH_TYPE_FACTORY

	UC_SHARED_STRING_EQUALITY_TESTER

feature {NONE} -- Initialization

	make is
			-- Populate types map.
		require
			types_not_populated: not types_created
		do
			-- TODO: need to bind all standard names
			make_common_types
			make_time_types
			make_numeric_types
			make_string_types
			
			types_created := True
			bind_names
		ensure
			types_populated: types_created
		end

feature -- Access

	types_created: BOOLEAN
			-- Have all types been created yet?

	schema_type (a_fingerprint: INTEGER): XM_XPATH_SCHEMA_TYPE is
			-- Schema type with fingerprint of `a_fingerprint'
		do
			if type_map.has (a_fingerprint) then
				Result := type_map.item (a_fingerprint)
			end
		end
	
	standard_fingerprint (a_uri, a_local_name: STRING): INTEGER is
			-- Fingerprint of a standard name
		local
			an_expanded_qname: STRING
		do
			an_expanded_qname := expanded_qname (a_uri, a_local_name)
			if fingerprint_map.has (an_expanded_qname) then
				Result := fingerprint_map.item (an_expanded_qname)
			else
				Result := -1
			end
		end

	standard_local_name (a_fingerprint: INTEGER): STRING is
			-- Extracted local name
		do
				check
					local_names.has (a_fingerprint)
					-- because of pre-condition
				end
			Result := local_names.item (a_fingerprint)
		end

	expanded_standard_name (a_fingerprint: INTEGER): STRING is
			-- Expanded name of `a_fingerprint'
		require
			standard_fingerprint: a_fingerprint < 1024
		local
			a_uri: STRING
		do
			a_uri := standard_uri (a_fingerprint)
			if a_uri.count = 0 then
				Result := standard_local_name (a_fingerprint)
			else
			end
		ensure
			expanded_name_not_void: Result /= Void
		end
			

	any_simple_type: XM_XPATH_ANY_SIMPLE_TYPE is
			-- xs:anySimpleType
		once
			create Result.make
		end

	any_atomic_type: XM_XPATH_ATOMIC_TYPE is
			-- xdt:anyAtomicType
		once
			create Result.make (Void, Xpath_defined_datatypes_uri,"anyAtomicType", any_simple_type, Any_atomic_type_code)
		end

	numeric_type: XM_XPATH_ATOMIC_TYPE is
			-- Implementation convenience type: gexslt:numeric
		once
			create Result.make (Void, Gexslt_eiffel_type_uri, "numeric", any_atomic_type, Numeric_type_code)
		end

	string_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:string
		once
			create Result.make (Void, Xml_schema_uri, "string", any_atomic_type, String_type_code)
		end

	boolean_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:boolean
		once
			create Result.make (Void,  Xml_schema_uri, "boolean", any_atomic_type, Boolean_type_code)
		end

	date_time_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:dateTime
		once
			create Result.make (Void,  Xml_schema_uri, "dateTime", any_atomic_type, Date_time_type_code)
		end

	date_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:date
		once
			create Result.make (Void,  Xml_schema_uri, "date", any_atomic_type, Date_type_code)
		end

	time_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:time
		once
			create Result.make (Void,  Xml_schema_uri, "time", any_atomic_type, Time_type_code)
		end

	any_uri_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:anyURI
		once
			create Result.make (Void,  Xml_schema_uri, "anyURI", any_atomic_type, Any_uri_type_code)
		end

	qname_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:QName
		once
			create Result.make (Void,  Xml_schema_uri, "QName", any_atomic_type, Qname_type_code)
		end

	untyped_atomic_type: XM_XPATH_ATOMIC_TYPE is
			-- xdt:untypedAtomic
		once
			create Result.make (Void, Xpath_defined_datatypes_uri, "untypedAtomic", any_atomic_type, Untyped_atomic_type_code)
		end

	decimal_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:decimal
		once
			create Result.make (Void,  Xml_schema_uri, "decimal", numeric_type, Decimal_type_code)
		end

	double_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:double
		once
			create Result.make (Void,  Xml_schema_uri, "double", numeric_type, Double_type_code)
		end

	integer_type: XM_XPATH_ATOMIC_TYPE is
			-- xs:integer
		once
			create Result.make (Void,  Xml_schema_uri, "integer", decimal_type, Integer_type_code)
		end

	any_type: XM_XPATH_ANY_TYPE is
			-- xs:anyType
		once
			create Result.make
		end

	untyped_type: XM_XPATH_UNTYPED_TYPE is
			-- xdt:untyped
		once
			create Result.make
		end
		
	object_type: XM_XPATH_SIMPLE_TYPE is
			-- Extension functions - gexslt:object
		do
			-- TODO
		end

feature {NONE} -- Implementation

	type_map: DS_HASH_TABLE [XM_XPATH_SCHEMA_TYPE, INTEGER] is
			-- Table of built-in types, keyed on fingerprint
		once
			create Result.make (1024)

			-- Add all types required by a Basic-level XSLT processor

			Result.put (any_simple_type, Any_simple_type_code)
			Result.put (any_atomic_type, Any_atomic_type_code)
			Result.put (boolean_type, Boolean_type_code)
			Result.put (numeric_type, Numeric_type_code)
			Result.put (string_type, String_type_code)
			Result.put (date_time_type, Date_time_type_code)
			Result.put (date_type, Date_type_code)
			Result.put (time_type, Time_type_code)
			Result.put (any_uri_type, Any_uri_type_code)
			Result.put (qname_type, Qname_type_code)
			Result.put (untyped_atomic_type, Untyped_atomic_type_code)
			Result.put (decimal_type, Decimal_type_code)			
			Result.put (double_type, Double_type_code)
			Result.put (integer_type, Integer_type_code)
			Result.put (any_type, Any_type_code)
			Result.put (untyped_type, Untyped_type_code)
			Result.put (year_month_duration_type, Year_month_duration_type_code)
			Result.put (day_time_duration_type, Day_time_duration_type_code)

			-- Conditionally add optional types

			if object_type /= Void then Result.put (object_type, Object_type_code) end
			if duration_type /= Void then Result.put (duration_type, Duration_type_code) end
			if g_year_month_type /= Void then Result.put (duration_type, Duration_type_code) end
			if g_month_type /= Void then Result.put (g_month_type, G_month_type_code) end
			if g_month_day_type /= Void then Result.put (g_month_day_type, G_month_day_type_code) end
			if g_year_type /= Void then Result.put (g_year_type, G_year_type_code) end
			if g_day_type /= Void then Result.put (g_day_type, G_day_type_code) end
			if hex_binary_type /= Void then Result.put (hex_binary_type, Hex_binary_type_code) end
			if base64_binary_type /= Void then Result.put (base64_binary_type, Base64_binary_type_code) end
			if notation_type /= Void then Result.put (notation_type, Notation_type_code) end
			if float_type /= Void then Result.put (float_type, Float_type_code) end
			if non_positive_integer_type /= Void then Result.put (non_positive_integer_type, Non_positive_integer_type_code) end
			if negative_integer_type /= Void then Result.put (negative_integer_type, Negative_integer_type_code) end
			if long_type /= Void then Result.put (long_type, Long_type_code) end
			if int_type /= Void then Result.put (int_type, Int_type_code) end
			if short_type /= Void then Result.put (short_type, Short_type_code) end
			if byte_type /= Void then Result.put (byte_type, Byte_type_code) end
			if non_negative_integer_type /= Void then Result.put (non_negative_integer_type, Non_negative_integer_type_code) end
			if positive_integer_type /= Void then Result.put (positive_integer_type, Positive_integer_type_code) end
			if unsigned_long_type /= Void then Result.put (unsigned_long_type, Unsigned_long_type_code) end
			if unsigned_int_type /= Void then Result.put (unsigned_int_type, Unsigned_int_type_code) end
			if unsigned_short_type /= Void then Result.put (unsigned_short_type, Unsigned_short_type_code) end
			if unsigned_byte_type /= Void then Result.put (unsigned_byte_type, Unsigned_byte_type_code) end
			if normalized_string_type /= Void then Result.put (normalized_string_type, Normalized_string_type_code) end
			if token_type /= Void then Result.put (token_type, Token_type_code) end
			if language_type /= Void then Result.put (language_type, Language_type_code) end
			if nmtoken_type /= Void then Result.put (nmtoken_type, Nmtoken_type_code) end
			if name_type /= Void then Result.put (name_type, Name_type_code) end
			if ncname_type /= Void then Result.put (ncname_type, Ncname_type_code) end
			if id_type /= Void then Result.put (id_type, Id_type_code) end
			if idref_type /= Void then Result.put (idref_type, Idref_type_code) end
			if entity_type /= Void then Result.put (entity_type, Entity_type_code) end
			if idrefs_type /= Void then Result.put (idrefs_type, Idrefs_type_code) end
			if entities_type /= Void then Result.put (entities_type, Entities_type_code) end
			if nmtokens_type /= Void then Result.put (nmtokens_type, Nmtokens_type_code) end
		ensure
			type_map_not_void: Result /= Void
			no_void_type: not Result.has_item (Void)
		end

	fingerprint_map: DS_HASH_TABLE [INTEGER, STRING] is
			-- Table of standard fingerprints, keyed on expanded QName
		once
			create Result.make_with_equality_testers (1024, Void, string_equality_tester)
		end

	local_names: DS_HASH_TABLE [STRING, INTEGER] is
			-- Table of standard local names, keyed on fingerprint
		once
			create Result.make (1024)
			Result.set_equality_tester (string_equality_tester)
		end

	expanded_qname (a_uri, a_local_name: STRING): STRING is
			-- The expanded QName (Clark name) of `a_uri' paired with `a_local_name'
		require
			namespace_not_void: a_uri /= Void
			local_name_not_void: a_local_name /= Void
		do
			Result := STRING_.appended_string ("{", a_uri)
			Result := STRING_.appended_string (Result, "}")
			Result := STRING_.appended_string (Result, a_local_name)
		ensure
			correct_length: Result.count = a_uri.count + a_local_name.count + 2
		end

	bind_xml_name (a_fingerprint: INTEGER; a_local_name: STRING) is
			-- Bind `a_local_name' to `a_fingerprint' in the XML namespace.
		require
			local_name_not_void: a_local_name /= void and then a_local_name.count > 0
			system_fingerprint: is_built_in_fingerprint (a_fingerprint)
			name_not_bound: not fingerprint_map.has (expanded_qname (Xml_uri, a_local_name))
			local_name_not_mapped: not local_names.has (a_fingerprint)
		do
			fingerprint_map.put (a_fingerprint, expanded_qname (Xml_uri, a_local_name))
			local_names.put (a_local_name, a_fingerprint)
		ensure
			local_name: local_names.has (a_fingerprint) and then STRING_.same_string (local_names.item (a_fingerprint), a_local_name)
			name_bound: fingerprint_map.has (expanded_qname (Xml_uri, a_local_name)) and then fingerprint_map.item (expanded_qname (Xml_uri, a_local_name)) = a_fingerprint
		end

	bind_xslt_name (a_fingerprint: INTEGER; a_local_name: STRING) is
			-- Bind `a_local_name' to `a_fingerprint' in the XSLT namespace.
		require
			local_name_not_void: a_local_name /= void and then a_local_name.count > 0
			system_fingerprint: is_built_in_fingerprint (a_fingerprint)
			name_not_bound: not fingerprint_map.has (expanded_qname (Xslt_uri, a_local_name))
			local_name_not_mapped: not local_names.has (a_fingerprint)
		do
			fingerprint_map.put (a_fingerprint, expanded_qname (Xslt_uri, a_local_name))
			local_names.put (a_local_name, a_fingerprint)
		ensure
			local_name: local_names.has (a_fingerprint) and then STRING_.same_string (local_names.item (a_fingerprint), a_local_name)
			name_bound: fingerprint_map.has (expanded_qname (Xslt_uri, a_local_name)) and then fingerprint_map.item (expanded_qname (Xslt_uri, a_local_name)) = a_fingerprint
		end

	bind_xs_name (a_fingerprint: INTEGER; a_local_name: STRING) is
			-- Bind `a_local_name' to `a_fingerprint' in the XML Schema namespace.
		require
			local_name_not_void: a_local_name /= void and then a_local_name.count > 0
			system_fingerprint: is_built_in_fingerprint (a_fingerprint)
			name_not_bound: not fingerprint_map.has (expanded_qname (Xml_schema_uri, a_local_name))
			local_name_not_mapped: not local_names.has (a_fingerprint)
		do
			fingerprint_map.put (a_fingerprint, expanded_qname (Xml_schema_uri, a_local_name))
			local_names.put (a_local_name, a_fingerprint)
		ensure
			name_bound: fingerprint_map.has (expanded_qname (Xml_schema_uri, a_local_name)) and then fingerprint_map.item (expanded_qname (Xml_schema_uri, a_local_name)) = a_fingerprint
			local_name: local_names.has (a_fingerprint) and then STRING_.same_string (local_names.item (a_fingerprint), a_local_name)
		end

	bind_xsi_name (a_fingerprint: INTEGER; a_local_name: STRING) is
			-- Bind `a_local_name' to `a_fingerprint' in the XML Schema Instance namespace.
		require
			local_name_not_void: a_local_name /= void and then a_local_name.count > 0
			system_fingerprint: is_built_in_fingerprint (a_fingerprint)
			name_not_bound: not fingerprint_map.has (expanded_qname (Xml_schema_instance_uri, a_local_name))
			local_name_not_mapped: not local_names.has (a_fingerprint)
		do
			fingerprint_map.put (a_fingerprint, expanded_qname (Xml_schema_instance_uri, a_local_name))
			local_names.put (a_local_name, a_fingerprint)
		ensure
			name_bound: fingerprint_map.has (expanded_qname (Xml_schema_instance_uri, a_local_name)) and then fingerprint_map.item (expanded_qname (Xml_schema_instance_uri, a_local_name)) = a_fingerprint
			local_name: local_names.has (a_fingerprint) and then STRING_.same_string (local_names.item (a_fingerprint), a_local_name)
		end

	bind_xdt_name (a_fingerprint: INTEGER; a_local_name: STRING) is
			-- Bind `a_local_name' to `a_fingerprint' in the XPath datatypes namespace.
		require
			local_name_not_void: a_local_name /= void and then a_local_name.count > 0
			system_fingerprint: is_built_in_fingerprint (a_fingerprint)
			name_not_bound: not fingerprint_map.has (expanded_qname (Xpath_defined_datatypes_uri, a_local_name))
			local_name_not_mapped: not local_names.has (a_fingerprint)
		do
			fingerprint_map.put (a_fingerprint, expanded_qname (Xpath_defined_datatypes_uri, a_local_name))
			local_names.put (a_local_name, a_fingerprint)
		ensure
			name_bound: fingerprint_map.has (expanded_qname (Xpath_defined_datatypes_uri, a_local_name)) and then fingerprint_map.item (expanded_qname (Xpath_defined_datatypes_uri, a_local_name)) = a_fingerprint
			local_name: local_names.has (a_fingerprint) and then STRING_.same_string (local_names.item (a_fingerprint), a_local_name)
		end

	bind_gexslt_name (a_fingerprint: INTEGER; a_local_name: STRING) is
			-- Bind `a_local_name' to `a_fingerprint' in the gexslt extensions namespace.
		require
			local_name_not_void: a_local_name /= void and then a_local_name.count > 0
			system_fingerprint: is_built_in_fingerprint (a_fingerprint)
			name_not_bound: not fingerprint_map.has (expanded_qname (Gexslt_eiffel_type_uri, a_local_name))
			local_name_not_mapped: not local_names.has (a_fingerprint)
		do
			fingerprint_map.put (a_fingerprint, expanded_qname (Gexslt_eiffel_type_uri, a_local_name))
			local_names.put (a_local_name, a_fingerprint)
		ensure
			name_bound: fingerprint_map.has (expanded_qname (Gexslt_eiffel_type_uri, a_local_name)) and then fingerprint_map.item (expanded_qname (Gexslt_eiffel_type_uri, a_local_name)) = a_fingerprint
			local_name: local_names.has (a_fingerprint) and then STRING_.same_string (local_names.item (a_fingerprint), a_local_name)
		end

	make_common_types is
			-- Populate types map with types common to all environments.
		require
			types_not_populated: not types_created
		local
			a_type: XM_XPATH_ITEM_TYPE
		do
			a_type := any_simple_type; a_type := any_atomic_type
			a_type := numeric_type; a_type := string_type
			a_type := boolean_type; a_type := date_time_type
			a_type := date_type; a_type := time_type
			a_type := qname_type; a_type := any_uri_type
			a_type := untyped_atomic_type; a_type := decimal_type
			a_type := integer_type; a_type := double_type
			a_type := untyped_type; a_type := any_type
		end

	make_time_types is
			-- Populate types map with time-related types.
		require
			types_not_populated: not types_created
		local
			a_type: XM_XPATH_ITEM_TYPE
		do
			a_type := duration_type; a_type := g_year_month_type
			a_type := g_month_type; a_type := g_month_day_type
			a_type := g_year_type; a_type := g_day_type
			a_type := year_month_duration_type; a_type := day_time_duration_type
		end

	make_numeric_types is
			-- Populate types map with numeric types.
		require
			types_not_populated: not types_created
		local
			a_type: XM_XPATH_ITEM_TYPE
		do
			a_type := hex_binary_type; a_type := base64_binary_type
			a_type := float_type; a_type := non_positive_integer_type
			a_type := negative_integer_type; a_type := long_type
			a_type := int_type; a_type := short_type
			a_type := byte_type; a_type := non_negative_integer_type
			a_type := positive_integer_type; a_type := unsigned_long_type
			a_type := unsigned_int_type; a_type := unsigned_short_type
			a_type := unsigned_byte_type
		end

	make_string_types is
			-- Populate types map with string types.
		require
			types_not_populated: not types_created
		local
			a_type: XM_XPATH_ITEM_TYPE
		do
			a_type := notation_type; a_type := normalized_string_type
			a_type := token_type; a_type := language_type
			a_type := nmtoken_type; a_type := name_type
			a_type := ncname_type; a_type := id_type
			a_type := idref_type; a_type := entity_type
			a_type := idrefs_type; a_type := entities_type
			a_type := nmtokens_type
		end

	bind_names is
			-- Bind all standard names to their fingerprints.
		do
			bind_xslt_names
			bind_xml_names
			bind_xsi_names
			bind_xdt_names
			bind_gexslt_names
			bind_xml_schema_names
		end

	bind_gexslt_names is
			-- Bind names specific to Gobo to their fingerprints.
		do
			bind_gexslt_name (Numeric_type_code, "numeric")
			bind_gexslt_name (Explain_type_code, "explain")
		end
	
	bind_xdt_names is
			-- Bind names in the XPath datatypes namespace to their fingerprints.
		do
			bind_xdt_name (Any_atomic_type_code, "anyAtomicType")
			bind_xdt_name (Untyped_atomic_type_code, "untypedAtomic")
			bind_xdt_name (Untyped_type_code, "untyped")
			bind_xdt_name (Year_month_duration_type_code, "yearMonthDuration")
			bind_xdt_name (Day_time_duration_type_code, "dayTimeDuration")
		end

	bind_xsi_names is
			-- Bind names in the XML Shcema Instance namespace to their fingerprints.
		do
			bind_xsi_name (Xsi_type_type_code, "type")
			bind_xsi_name (Xsi_nil_type_code, "nil")
			bind_xsi_name (Xsi_schema_location_type_code, "schemaLocation")
			bind_xsi_name (Xsi_no_namespace_schema_location_type_code, "noNamespaceSchemaLocation")
		end
	
	bind_xml_names is
			-- Bind names in the XML namespace to their fingerprints.
		do
			bind_xml_name (Xml_base_type_code, "base")
			bind_xml_name (Xml_space_type_code, "space")
			bind_xml_name (Xml_lang_type_code, "lang")
		end
	
	bind_xslt_names is
			-- Bind names in the XSLT namespace to their fingerprints.
		do
			bind_xslt_name (Xslt_analyze_string_type_code, "analyze-string")
			bind_xslt_name (Xslt_apply_imports_type_code, "apply-imports")
			bind_xslt_name (Xslt_apply_templates_type_code, "apply-templates")
			bind_xslt_name (Xslt_attribute_type_code, "attribute")
			bind_xslt_name (Xslt_attribute_set_type_code, "attribute-set")
			bind_xslt_name (Xslt_call_template_type_code, "call-template")
			bind_xslt_name (Xslt_character_map_type_code, "character-map")
			bind_xslt_name (Xslt_choose_type_code, "choose")
			bind_xslt_name (Xslt_comment_type_code, "comment")
			bind_xslt_name (Xslt_copy_type_code, "copy")
			bind_xslt_name (Xslt_copy_of_type_code, "copy-of")
			bind_xslt_name (Xslt_decimal_format_type_code, "decimal-format")
			bind_xslt_name (Xslt_document_type_code, "document")
			bind_xslt_name (Xslt_element_type_code, "element")
			bind_xslt_name (Xslt_fallback_type_code, "fallback")
			bind_xslt_name (Xslt_for_each_type_code, "for-each")
			bind_xslt_name (Xslt_for_each_group_type_code, "for-each-group")
			bind_xslt_name (Xslt_function_type_code, "function")
			bind_xslt_name (Xslt_if_type_code, "if")
			bind_xslt_name (Xslt_import_type_code, "import")
			bind_xslt_name (Xslt_import_schema_type_code, "import-schema")
			bind_xslt_name (Xslt_include_type_code, "include")
			bind_xslt_name (Xslt_key_type_code, "key")
			bind_xslt_name (Xslt_matching_substring_type_code, "matching-substring")
			bind_xslt_name (Xslt_message_type_code, "message")
			bind_xslt_name (Xslt_next_match_type_code, "next-match")
			bind_xslt_name (Xslt_number_type_code, "number")
			bind_xslt_name (Xslt_namespace_type_code, "namespace")
			bind_xslt_name (Xslt_namespace_alias_type_code, "namespace-alias")
			bind_xslt_name (Xslt_non_matching_substring_type_code, "non-matching-substring")
			bind_xslt_name (Xslt_otherwise_type_code, "otherwise")
			bind_xslt_name (Xslt_output_type_code, "output")
			bind_xslt_name (Xslt_output_character_type_code, "output-character")
			bind_xslt_name (Xslt_param_type_code, "param")
			bind_xslt_name (Xslt_perform_sort_type_code, "perform-sort")
			bind_xslt_name (Xslt_preserve_space_type_code, "preserve-space")
			bind_xslt_name (Xslt_processing_instruction_type_code, "processing-instruction")
			bind_xslt_name (Xslt_result_document_type_code, "result-document")
			bind_xslt_name (Xslt_sequence_type_code, "sequence")
			bind_xslt_name (Xslt_sort_type_code, "sort")
			bind_xslt_name (Xslt_strip_space_type_code, "strip-space")
			bind_xslt_name (Xslt_stylesheet_type_code, "stylesheet")
			bind_xslt_name (Xslt_template_type_code, "template")
			bind_xslt_name (Xslt_text_type_code, "text")
			bind_xslt_name (Xslt_transform_type_code, "transform")
			bind_xslt_name (Xslt_value_of_type_code, "value-of")
			bind_xslt_name (Xslt_variable_type_code, "variable")
			bind_xslt_name (Xslt_with_param_type_code, "with-param")
			bind_xslt_name (Xslt_when_type_code, "when")
			bind_xslt_name (Xslt_xpath_default_namespace_type_code, "xpath-default-namespace")
			bind_xslt_name (Xslt_exclude_result_prefixes_type_code, "exclude-result-prefixes")
			bind_xslt_name (Xslt_extension_element_prefixes_type_code, "extension-element-prefixes")
			bind_xslt_name (Xslt_type_type_code, "type")
			bind_xslt_name (Xslt_use_attribute_sets_type_code, "use-attribute-sets")
			bind_xslt_name (Xslt_validation_type_code, "validation")
			bind_xslt_name (Xslt_version_type_code, "version")
		end

	bind_xml_schema_names is
			-- Bind names in XML Schema namespace to their fingerprints.
		do
			bind_xs_name (String_type_code, "string")
			bind_xs_name (Boolean_type_code, "boolean")
			bind_xs_name (Decimal_type_code, "decimal")
			bind_xs_name (Float_type_code, "float")
			bind_xs_name (Double_type_code, "double")
			bind_xs_name (Duration_type_code, "duration")
			bind_xs_name (Date_time_type_code, "dateTime")
			bind_xs_name (Date_type_code, "date")
			bind_xs_name (Time_type_code, "time")
			bind_xs_name (G_year_month_type_code, "gYearMonth")
			bind_xs_name (G_year_type_code, "gYear")
			bind_xs_name (G_month_day_type_code, "gMonthDay")
			bind_xs_name (G_day_type_code, "gDay")
			bind_xs_name (G_month_type_code, "gMonth")
			bind_xs_name (Hex_binary_type_code, "hexBinary")
			bind_xs_name (Base64_binary_type_code, "base64Binary")
			bind_xs_name (Any_uri_type_code, "anyURI")
			bind_xs_name (Qname_type_code, "QName")
			bind_xs_name (Notation_type_code, "NOTATION")
			bind_xs_name (Integer_type_code, "integer")
			bind_xs_name (Non_positive_integer_type_code, "nonPositiveInteger")
			bind_xs_name (Negative_integer_type_code, "negativeInteger")
			bind_xs_name (Long_type_code, "long")
			bind_xs_name (Int_type_code, "int")
			bind_xs_name (Short_type_code, "short")
			bind_xs_name (Byte_type_code, "byte")
			bind_xs_name (Non_negative_integer_type_code, "nonNegativeInteger")
			bind_xs_name (Positive_integer_type_code, "positiveInteger")
			bind_xs_name (Unsigned_long_type_code, "unsignedLong")
			bind_xs_name (Unsigned_int_type_code, "unsignedInt")
			bind_xs_name (Unsigned_short_type_code, "unsignedShort")
			bind_xs_name (Unsigned_byte_type_code, "unsignedByte")
			bind_xs_name (Normalized_string_type_code, "normalizedString")
			bind_xs_name (Token_type_code, "token")
			bind_xs_name (Language_type_code, "language")
			bind_xs_name (Nmtoken_type_code, "NMTOKEN")
			bind_xs_name (Nmtokens_type_code, "NMTOKENS")
			bind_xs_name (Name_type_code, "Name")
			bind_xs_name (Ncname_type_code, "NCName")
			bind_xs_name (Id_type_code, "ID")
			bind_xs_name (Idref_type_code, "IDREF")
			bind_xs_name (Idrefs_type_code, "IDREFS")
			bind_xs_name (Entity_type_code, "ENTITY")
			bind_xs_name (Entities_type_code, "ENTITIES")
			bind_xs_name (Any_type_code, "any")
			bind_xs_name (Any_simple_type_code, "anySimpleType")
		end

invariant

	type_map_not_void: type_map /= Void

end
	