indexing

	description:

		"Output definitions"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_OUTPUT_PROPERTIES

inherit

	XM_XSLT_OUTPUT_ROUTINES

	UC_SHARED_STRING_EQUALITY_TESTER

	XM_XPATH_STANDARD_NAMESPACES

	XM_XPATH_SHARED_NAME_POOL

creation

	make

feature {NONE} -- Initialization

	make (an_import_precedence: INTEGER) is
			-- Make with defaults for XML method (apart from method itself).
		do
			initialize
			set_xml_defaults (an_import_precedence)
			method := ""
		end

	initialize is
			-- Initialize.
		do
			create extension_attributes.make_with_equality_testers (1, string_equality_tester, string_equality_tester)
			create string_property_map.make_with_equality_testers (3, string_equality_tester, string_equality_tester)
			create boolean_property_map.make_with_equality_testers (1, Void, string_equality_tester)
			create precedence_property_map.make_with_equality_testers (1, Void, string_equality_tester)
			create cdata_section_elements.make_default
			cdata_section_elements.set_equality_tester (string_equality_tester)			
			create used_character_maps.make_default
			used_character_maps.set_equality_tester (string_equality_tester)
			set_default_indent_spaces (3)           -- this is not specified in any way by the spec
			set_default_encoding ("UTF-8")
			set_default_byte_order_mark (False)
			set_default_escape_uri_attributes (True)
			set_default_include_content_type (True)
		ensure
			encoding_set: STRING_.same_string (encoding, "UTF-8")
			uri_attributes_escaped: escape_uri_attributes
			content_type_included: include_content_type
		end

feature -- Access

	method: STRING
			-- Output method: "xml", "html", "xhtml", "text" or a QName

	version: STRING is
			-- Text of version attribute on xml declaration
		do
			if string_property_map.has (Version_attribute) then
				Result := string_property_map.item (Version_attribute)
			else
				Result := default_version
			end
		ensure
			version_not_void: Result /= Void
		end

	encoding: STRING
			-- Encoding to use

	cdata_section_elements: DS_HASH_SET [STRING]
			-- Expanded QNames of elements whose text-node children should be written as CDATA sections

	omit_xml_declaration: BOOLEAN
			-- Should the xml declaration be omitted?

	standalone: STRING
			-- Value of the standalone attribute on the xml declaration

	doctype_public: STRING
			-- Value of the PUBLIC identifier to be written on the DOCTYPE

	doctype_system: STRING
			-- Value of the SYSTEM identifier to be written on the DOCTYPE

	indent: BOOLEAN is
			-- Should the transformer add additional whitespace?
		do
			if boolean_property_map.has (Indent_attribute) then
				Result := boolean_property_map.item (Indent_attribute)
			else
				Result := default_indent
			end
		end

	media_type: STRING is
			-- MIME type to be written
		do
			if string_property_map.has (Media_type_attribute) then
				Result := string_property_map.item (Media_type_attribute)
			else
				Result := default_media_type
			end
		ensure
			media_type_not_void: Result /= Void
		end

	is_higher_precedence (an_import_precedence: INTEGER; a_property: STRING): BOOLEAN is
			-- Is `an_import_precedence' greater than the import precednece used when previously defining `a_property'?
		require
			valid_property_name: a_property /= Void and then a_property.count > 0
		do
			if precedence_property_map.has (a_property) then
				Result := an_import_precedence > precedence_property_map.item (a_property)
			else
				Result := True
			end
		end

	is_lower_precedence (an_import_precedence: INTEGER; a_property: STRING): BOOLEAN is
			-- Is `an_import_precedence' lower than the import precednece used when previously defining `a_property'?
		require
			valid_property_name: a_property /= Void and then a_property.count > 0
		do
			if precedence_property_map.has (a_property) then
				Result := an_import_precedence < precedence_property_map.item (a_property)
			end
		end

	indent_spaces: INTEGER
			-- Number of spaces to be used for indentation when `indent' is `True' (a gexslt extension)

	used_character_maps: DS_ARRAYED_LIST [STRING]
			-- Expanded QNames of character maps that are to be used

	include_content_type: BOOLEAN
			-- Should the html/xhtml methods write a Content-type meta element within the head element?

	undeclare_namespaces: BOOLEAN
			-- Should the xml method (for version 1.1) write namespace undeclarations?

	escape_uri_attributes: BOOLEAN
			-- Should the html and xhtml methods escape non-ASCII charaters in URI attribute values?

	byte_order_mark_required: BOOLEAN
			-- Should emitter write a BOM?

	character_representation: STRING is
			-- How should characters be represented (a gexslt extension)?
		do
			if string_property_map.has (Gexslt_character_representation_attribute) then
				Result := string_property_map.item (Gexslt_character_representation_attribute)
			else
				Result := default_character_representation
			end
		ensure
			character_representation_not_void: Result /= Void
			valid_character_representation: is_valid_character_representation (Result)
		end

	is_valid_character_representation (a_character_representation: STRING): BOOLEAN is
			-- Is `a_character_representation' valid for `character_representation'? 
		require
			character_representation_not_void: a_character_representation /= Void
		local
			a_splitter: ST_SPLITTER
			representations: DS_LIST [STRING]
			a_non_ascii_representation, an_excluded_representation: STRING
		do
			create a_splitter.make
			a_splitter.set_separators (";")
			representations := a_splitter.split (a_character_representation)
			if representations.count = 0 then
				Result := False
			elseif representations.count > 2 then
				Result := False
			else
				if representations.count = 1 then
					a_non_ascii_representation := representations.item (1)
					an_excluded_representation := representations.item (1)
				elseif representations.count = 2 then
					a_non_ascii_representation := representations.item (1)
					an_excluded_representation := representations.item (2)
				end
				STRING_.left_adjust (a_non_ascii_representation)
				STRING_.right_adjust (a_non_ascii_representation)
				STRING_.left_adjust (an_excluded_representation)
				STRING_.right_adjust (an_excluded_representation)
				if STRING_.same_string (method, "xml") then
					Result := STRING_.same_string (a_non_ascii_representation, "hex")
						or else STRING_.same_string (a_non_ascii_representation, "decimal")
				elseif STRING_.same_string (method, "text") then
					Result := True
				else
					Result := (STRING_.same_string (a_non_ascii_representation, "hex")
								  or else STRING_.same_string (a_non_ascii_representation, "decimal")
								  or else STRING_.same_string (a_non_ascii_representation, "native")
								  or else STRING_.same_string (a_non_ascii_representation, "entity"))
						and then (STRING_.same_string (an_excluded_representation, "hex")
									 or else STRING_.same_string (a_non_ascii_representation, "decimal")
									 or else STRING_.same_string (a_non_ascii_representation, "entity"))
				end
			end
		end

	extension_attributes: DS_HASH_TABLE [STRING, STRING]
		-- Extension attributs for use by QName methods

feature -- Status report

	is_error: BOOLEAN
			-- Has an error been reported?

	is_duplication_error: BOOLEAN
			-- Is the error a duplication error?

	error_message: STRING
			-- Error message from `set_property'

	duplicate_attribute_name: STRING
			-- Name of attribute that caused a duplication error

feature -- Status setting

	set_duplication_error (an_attribute_name: STRING) is
			-- Indicate `an_attribute_name' is invalidly specified twice.
		require
			attribute_name_not_void: an_attribute_name /= Void and then an_attribute_name.count > 0
			no_previous_error: not is_error
		do
			duplicate_attribute_name := an_attribute_name
			is_error := True
			is_duplication_error := True
		ensure
			in_error: is_error and then is_duplication_error
			name_set: STRING_.same_string (duplicate_attribute_name, an_attribute_name)
		end

	set_general_error (an_error_message: STRING) is
			-- Set a general error, other than a duplication error.
		require
			error_message_not_void: an_error_message /= Void
			no_previous_error: not is_error
		do
			error_message := an_error_message
			is_error := True
		ensure
			in_error: is_error and then not is_duplication_error
			error_text_set: STRING_.same_string (error_message, an_error_message)
		end

feature -- Element change

	set_xml_defaults (an_import_precedence: INTEGER) is
			-- Set defaults suitable for xml method.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Method_attribute)
		do
			set_method ("xml", an_import_precedence)
			set_default_indent (False)
			set_default_version ("1.0")
			set_default_media_type ("text/xml")
			set_default_character_representation ("hex")
		ensure
			import_precedence_set: precedence_property_map.has (Method_attribute) and then precedence_property_map.item (Method_attribute) = an_import_precedence
			method_is_xml: STRING_.same_string (method, "xml")
			no_indentation: default_indent = False
			version_1_0: STRING_.same_string (default_version, "1.0")
			text_xml: STRING_.same_string (default_media_type, "text/xml")
			hex_character_representation: STRING_.same_string (default_character_representation, "hex")
		end

	set_html_defaults (an_import_precedence: INTEGER) is
			-- Set defaults suitable for html method.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Method_attribute)		
		do
			set_method ("html", an_import_precedence)
			set_default_indent (True)
			set_default_version ("4.01")
			set_default_media_type ("text/html")
			set_default_character_representation ("entity;decimal")
		ensure
			import_precedence_set: precedence_property_map.has (Method_attribute) and then precedence_property_map.item (Method_attribute) = an_import_precedence
			method_is_html: STRING_.same_string (method, "html")
			indentation: default_indent = True
			version_4_01: STRING_.same_string (default_version, "4.01")
			text_html: STRING_.same_string (default_media_type, "text/html")
			character_representation: STRING_.same_string (default_character_representation, "entity;decimal")			
		end

	set_xhtml_defaults (an_import_precedence: INTEGER) is
			-- Set defaults suitable for xhtml method.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Method_attribute)		
		do
			set_html_defaults (an_import_precedence)
			set_method ("xhtml", an_import_precedence)
			set_default_version ("1.0")
			set_default_character_representation ("hex")
		ensure
			import_precedence_set: precedence_property_map.has (Method_attribute) and then precedence_property_map.item (Method_attribute) = an_import_precedence
			method_is_xhtml: STRING_.same_string (method, "xhtml")
			indentation: default_indent = True
			version_1_0: STRING_.same_string (default_version, "1.0")
			text_html: STRING_.same_string (default_media_type, "text/html")
			hex_character_representation: STRING_.same_string (default_character_representation, "hex")
		end

	set_text_defaults (an_import_precedence: INTEGER) is
			-- Set defaults suitable for text method.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Method_attribute)		
		do
			set_method ("text", an_import_precedence)
			set_default_media_type ("text/plain")
		ensure
			import_precedence_set: precedence_property_map.has (Method_attribute) and then precedence_property_map.item (Method_attribute) = an_import_precedence
			method_is_text: STRING_.same_string (method, "text")
			text_plain: STRING_.same_string (default_media_type, "text/plain")
		end

	set_method (an_expanded_name: STRING ; an_import_precedence: INTEGER) is
			-- Set `method'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Version_attribute)
			name_not_void: an_expanded_name /= Void
		do
			precedence_property_map.force (an_import_precedence, Method_attribute)
			method := an_expanded_name
		ensure
			import_precedence_set: precedence_property_map.has (Method_attribute) and then precedence_property_map.item (Method_attribute) = an_import_precedence
			method_set: STRING_.same_string (method, an_expanded_name)
		end

	set_version (a_version: STRING; an_import_precedence: INTEGER) is
			--	Set `version'.
		require
			version_not_void: a_version /= Void -- and then
			higher_precedence: is_higher_precedence (an_import_precedence, Version_attribute)
		do
			precedence_property_map.force (an_import_precedence, Version_attribute)
			string_property_map.force (a_version, Version_attribute)
		ensure
			import_precedence_set: precedence_property_map.has (Version_attribute) and then precedence_property_map.item (Version_attribute) = an_import_precedence
			version_set: string_property_map.has (Version_attribute) and then STRING_.same_string (string_property_map.item (Version_attribute), a_version)
		end

	set_indent (an_indent_value: BOOLEAN; an_import_precedence: INTEGER) is
			-- Set `indent'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Indent_attribute)		
		do
			precedence_property_map.force (an_import_precedence, Indent_attribute)
			boolean_property_map.force (an_indent_value, Indent_attribute)
		ensure
			import_precedence_set: precedence_property_map.has (Indent_attribute) and then precedence_property_map.item (Indent_attribute) = an_import_precedence
			indent_set: boolean_property_map.has (Indent_attribute) and then boolean_property_map.item (Indent_attribute) = an_indent_value
		end

	set_omit_xml_declaration (an_omit_xml_declaration_value: BOOLEAN; an_import_precedence: INTEGER) is
			-- Set `omit_xml_declaration'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Omit_xml_declaration_attribute)	
		do
			precedence_property_map.force (an_import_precedence, Omit_xml_declaration_attribute)
			omit_xml_declaration := an_omit_xml_declaration_value
		ensure
			import_precedence_set: precedence_property_map.has (Omit_xml_declaration_attribute) and then precedence_property_map.item (Omit_xml_declaration_attribute) = an_import_precedence
			omit_xml_declaration_set: omit_xml_declaration = an_omit_xml_declaration_value
		end

	set_standalone (a_standalone_value: STRING; an_import_precedence: INTEGER) is
			-- Set `standalone'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Standalone_attribute)			
		do
			precedence_property_map.force (an_import_precedence, Standalone_attribute)
			standalone := a_standalone_value
		ensure
			import_precedence_set: precedence_property_map.has (Standalone_attribute) and then precedence_property_map.item (Standalone_attribute) = an_import_precedence
			standalone_set: standalone = a_standalone_value
		end

	set_indent_spaces (a_number: INTEGER; an_import_precedence: INTEGER) is
			-- Set `indent_spaces'
		require
			strictly_positive: a_number > 0
			higher_precedence: is_higher_precedence (an_import_precedence, Gexslt_indent_spaces_attribute)
		do
			precedence_property_map.force (an_import_precedence, Gexslt_indent_spaces_attribute)
			indent_spaces := a_number
		ensure
			import_precedence_set: precedence_property_map.has (Gexslt_indent_spaces_attribute) and then precedence_property_map.item (Gexslt_indent_spaces_attribute) = an_import_precedence
			indent_spaces_set: indent_spaces = a_number
		end

	set_encoding (an_encoding: STRING; an_import_precedence: INTEGER) is
			-- Set `encoding'.
		require
			encoding_not_void: an_encoding /= Void
			higher_precedence: is_higher_precedence (an_import_precedence, Encoding_attribute)
		do
			precedence_property_map.force (an_import_precedence, Encoding_attribute)
			encoding := STRING_.to_upper (an_encoding)
			if STRING_.same_string (encoding, "UTF-16") and then not precedence_property_map.has (Byte_order_mark_attribute) then
				byte_order_mark_required := True
			end
		ensure
			import_precedence_set: precedence_property_map.has (Encoding_attribute) and then precedence_property_map.item (Encoding_attribute) = an_import_precedence
			encoding_set: STRING_.same_string (encoding, STRING_.to_upper (an_encoding))
		end

	set_media_type (a_media_type: STRING; an_import_precedence: INTEGER) is
			-- Set `media_type'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Media_type_attribute)
			media_type_not_void: a_media_type /= Void --and then a_media_type.count > 0
		do
			precedence_property_map.force (an_import_precedence, Media_type_attribute)
			if not string_property_map.has (Media_type_attribute) then
				string_property_map.put (a_media_type, Media_type_attribute)
			end
		ensure
			import_precedence_set: precedence_property_map.has (Media_type_attribute) and then precedence_property_map.item (Media_type_attribute) = an_import_precedence
			media_type_set: STRING_.same_string (media_type , a_media_type)
		end

	set_doctype_system (a_system_id: STRING; an_import_precedence: INTEGER) is
			-- Set `doctype_system'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Doctype_system_attribute)
			doctype_system_not_void: a_system_id /= Void
		do
			precedence_property_map.force (an_import_precedence, Doctype_system_attribute)
			doctype_system := a_system_id
		ensure
			import_precedence_set: precedence_property_map.has (Doctype_system_attribute) and then precedence_property_map.item (Doctype_system_attribute) = an_import_precedence
			doctype_system_set: STRING_.same_string (a_system_id, doctype_system)
		end

	set_doctype_public (a_public_id: STRING; an_import_precedence: INTEGER) is
			-- Set `doctype_public'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Doctype_public_attribute)
			doctype_public_not_void: a_public_id /= Void
		do
			precedence_property_map.force (an_import_precedence, Doctype_public_attribute)
			doctype_public := a_public_id
		ensure
			import_precedence_set: precedence_property_map.has (Doctype_public_attribute) and then precedence_property_map.item (Doctype_public_attribute) = an_import_precedence
			doctype_public_set: STRING_.same_string (a_public_id, doctype_public)
		end

	set_cdata_sections (some_cdata_section_expanded_names:  DS_ARRAYED_LIST [STRING]) is
			-- Set `cdata_section_elements' by merger form `some_cdata_section_expanded_names'.
		require
			cdata_section_expanded_names_not_void: some_cdata_section_expanded_names /= Void
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [STRING]
			an_expanded_name: STRING
		do
			from
				a_cursor := some_cdata_section_expanded_names.new_cursor; a_cursor.start
			variant
				some_cdata_section_expanded_names.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				an_expanded_name := a_cursor.item
				if not cdata_section_elements.has (an_expanded_name) then
					if not shared_name_pool.is_expanded_name_allocated (an_expanded_name) then
						shared_name_pool.allocate_expanded_name (an_expanded_name)
					end
					cdata_section_elements.force (an_expanded_name)
				end
				a_cursor.forth
			end
		end

	set_undeclare_namespaces (an_undeclare_namespaces_value: BOOLEAN; an_import_precedence: INTEGER) is
			-- Set `undeclare_namespaces'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Undeclare_namespaces_attribute)
		do
			precedence_property_map.force (an_import_precedence, Undeclare_namespaces_attribute)
			undeclare_namespaces := an_undeclare_namespaces_value
		ensure
			import_precedence_set: precedence_property_map.has (Undeclare_namespaces_attribute) and then precedence_property_map.item (Undeclare_namespaces_attribute) = an_import_precedence
			undeclare_namespaces_set: undeclare_namespaces = an_undeclare_namespaces_value
		end

	set_character_representation (a_character_representation: STRING; an_import_precedence: INTEGER) is
			-- Set `character_representation'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Gexslt_character_representation_attribute)
			character_representation_not_void: a_character_representation /= Void
			valid_character_representation: is_valid_character_representation (a_character_representation)
		do
			precedence_property_map.force (an_import_precedence, Gexslt_character_representation_attribute)
			if not string_property_map.has (Gexslt_character_representation_attribute) then
				string_property_map.put (a_character_representation, Gexslt_character_representation_attribute)
			end
		ensure
			import_precedence_set: precedence_property_map.has (Gexslt_character_representation_attribute) and then precedence_property_map.item (Gexslt_character_representation_attribute) = an_import_precedence
			character_representation_set: STRING_.same_string (character_representation , a_character_representation)			
		end

	set_include_content_type (an_include_content_type_value: BOOLEAN; an_import_precedence: INTEGER) is
			-- Set `include_content_type'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Include_content_type_attribute)		
		do
			precedence_property_map.force (an_import_precedence, Include_content_type_attribute)
			include_content_type := an_include_content_type_value
		ensure
			import_precedence_set: precedence_property_map.has (Include_content_type_attribute) and then precedence_property_map.item (Include_content_type_attribute) = an_import_precedence
			include_content_type_set: include_content_type = an_include_content_type_value
		end

	set_escape_uri_attributes (an_escape_uri_attributes_value: BOOLEAN; an_import_precedence: INTEGER) is
			-- Set `escape_uri_attributes'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Escape_uri_attributes_attribute)
		do
			precedence_property_map.force (an_import_precedence, Escape_uri_attributes_attribute)
			escape_uri_attributes := an_escape_uri_attributes_value
		ensure
			import_precedence_set: precedence_property_map.has (Escape_uri_attributes_attribute) and then precedence_property_map.item (Escape_uri_attributes_attribute) = an_import_precedence
			escape_uri_attributes_set: escape_uri_attributes = an_escape_uri_attributes_value
		end
										
	set_byte_order_mark_required (an_byte_order_mark_required_value: BOOLEAN; an_import_precedence: INTEGER) is
			-- Set `byte_order_mark_required'.
		require
			higher_precedence: is_higher_precedence (an_import_precedence, Byte_order_mark_attribute)			
		do
			precedence_property_map.force (an_import_precedence, Byte_order_mark_attribute)
			byte_order_mark_required := an_byte_order_mark_required_value
		ensure
			import_precedence_set: precedence_property_map.has (Byte_order_mark_attribute) and then precedence_property_map.item (Byte_order_mark_attribute) = an_import_precedence
			byte_order_mark_required_set: byte_order_mark_required = an_byte_order_mark_required_value
		end

	merge_extension_attributes (some_extension_attributes: like extension_attributes) is
			-- Merge in any extension attributes.
		require
			extension_attributes_not_void: some_extension_attributes /= Void
		local
			a_cursor: DS_HASH_TABLE_CURSOR [STRING, STRING]
		do
			from
				a_cursor := some_extension_attributes.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				extension_attributes.force (a_cursor.item, a_cursor.key)
				a_cursor.forth	
			end
		end

	set_property (a_fingerprint: INTEGER; a_value: STRING; a_namespace_resolver: XM_XPATH_NAMESPACE_RESOLVER) is
			-- Set any property identified by `a_fingerprint'.
			-- This is used by xsl:result-document to override an output definition.
		require
			positive_fingerprint: a_fingerprint > 0
			value_not_void: a_value /= Void
			namespace_resolver_not_void: a_namespace_resolver /= Void
			no_previous_error: not is_error
		local
			a_uri, a_local_name: STRING
		do
			a_uri := shared_name_pool.namespace_uri_from_name_code (a_fingerprint)
			a_local_name := shared_name_pool.local_name_from_name_code (a_fingerprint)
			if a_uri.count = 0 then
				set_standard_property (a_local_name, a_value, a_namespace_resolver)
			elseif STRING_.same_string (a_uri, Gexslt_eiffel_type_uri) then
				set_gexslt_property (a_local_name, a_value)
			else
				set_extension_property (a_uri, a_local_name, a_value)
			end
		ensure
			error_message_set: is_error implies error_message /= Void
		end

feature -- Duplication

	another: like Current is
			-- Deep clone of `Current'
		do
			Result := clone (Current)
			Result.clone_string_property_map (string_property_map)
			Result.clone_boolean_property_map (boolean_property_map)
			Result.clone_precedence_property_map (precedence_property_map)
			Result.clone_cdata_section_elements (cdata_section_elements)
			Result.clone_used_character_maps (used_character_maps)
		ensure
			result_not_void: Result /= Void
		end

feature {XM_XSLT_OUTPUT_PROPERTIES} -- Local
	
	clone_cdata_section_elements (some_cdata_section_elements: like cdata_section_elements) is
			-- Deeply clone `cdata_section_elements'.
		local
			a_cursor: DS_HASH_SET_CURSOR [STRING]
		do
			create cdata_section_elements.make (some_cdata_section_elements.count)
			cdata_section_elements.set_equality_tester (string_equality_tester)
			from
				a_cursor := some_cdata_section_elements.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				cdata_section_elements.put (clone (a_cursor.item))
				a_cursor.forth
			end
		end	

	clone_used_character_maps (some_used_character_maps: like used_character_maps) is
			-- Deeply clone `used_character_maps'.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [STRING]
		do
			create used_character_maps.make (some_used_character_maps.count)
			used_character_maps.set_equality_tester (string_equality_tester)
			from
				a_cursor := some_used_character_maps.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				used_character_maps.put_last (clone (a_cursor.item))
				a_cursor.forth
			end
		end

	clone_string_property_map (a_string_property_map: like string_property_map) is
			-- Deeply clone `string_property_map'.
		local
			a_cursor: DS_HASH_TABLE_CURSOR [STRING, STRING]
		do
			create string_property_map.make_with_equality_testers (a_string_property_map.count, string_equality_tester, string_equality_tester)
			from
				a_cursor := a_string_property_map.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				string_property_map.put (clone (a_cursor.item), clone (a_cursor.key))
				a_cursor.forth
			end
		end

	clone_boolean_property_map (a_boolean_property_map: like boolean_property_map) is
			-- Deeply clone `boolean_property_map'.
		local
			a_cursor: DS_HASH_TABLE_CURSOR [BOOLEAN, STRING]
		do
			create boolean_property_map.make_with_equality_testers (a_boolean_property_map.count, Void, string_equality_tester)
			from
				a_cursor := a_boolean_property_map.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				boolean_property_map.put (a_cursor.item, clone (a_cursor.key))
				a_cursor.forth
			end
		end
	
	clone_precedence_property_map (a_precedence_property_map: like precedence_property_map) is
			-- Deeply clone `precedence_property_map'.
		local
			a_cursor: DS_HASH_TABLE_CURSOR [INTEGER, STRING]
		do
			create precedence_property_map.make_with_equality_testers (a_precedence_property_map.count, Void, string_equality_tester)
			from
				a_cursor := a_precedence_property_map.new_cursor; a_cursor.start
			until
				a_cursor.after
			loop
				precedence_property_map.put (a_cursor.item, clone (a_cursor.key))
				a_cursor.forth
			end
		end
	
	set_extension_property (a_uri, a_local_name, a_value: STRING) is
			-- Set any property identified by `a_uri, a_local_name'.
			-- This is used by xsl:result-document to override an output definition.
		require
			namespace_not_void: a_uri /= Void
			local_name_not_void: a_local_name /= Void
			value_not_void: a_value /= Void
			no_previous_error: not is_error
		local
			an_expanded_name: STRING
		do
			an_expanded_name := STRING_.concat ("{", a_uri)
			an_expanded_name := STRING_.appended_string (an_expanded_name, "}")
			an_expanded_name := STRING_.appended_string (an_expanded_name, a_local_name)
			extension_attributes.force (a_value, an_expanded_name)
		end

feature {XM_XSLT_EXTENSION_EMITTER_FACTORY} -- Restricted

	set_default_indent (an_indent_value: BOOLEAN) is
			-- Set `default_indent'.
		do
			default_indent := an_indent_value
		ensure
			default_indent_set: default_indent = an_indent_value
		end

	set_default_version (a_version: STRING) is
			--	Set `default_version'.
		require
			version_not_void: a_version /= Void -- and then
		do
			default_version := a_version
		ensure
			version_set: default_version = a_version
		end
	
	set_default_media_type (a_media_type: STRING) is
			-- Set `default_media_type'.
		require
			media_type_not_void: a_media_type /= Void --and then a_media_type.count > 0
		do
			default_media_type := a_media_type
		ensure
			media_type_set: default_media_type = a_media_type
		end

	set_default_character_representation (a_character_representation: STRING) is
			-- Set `default_character_representation'.
		require
			character_representation_not_void: a_character_representation /= Void
			valid_character_representation: is_valid_character_representation (a_character_representation)
		do
			default_character_representation := a_character_representation
		ensure
			character_representation_set: default_character_representation = a_character_representation
		end

	set_default_indent_spaces (a_number: INTEGER) is
			-- Set default for `indent_spaces'
		require
			strictly_positive: a_number > 0
		do
			indent_spaces := a_number
		ensure
			indent_spaces_set: indent_spaces = a_number
		end

	set_default_encoding (an_encoding: STRING) is
			-- Set `encoding'.
		require
			encoding_not_void: an_encoding /= Void
		do
			encoding := STRING_.to_upper (an_encoding)
		ensure
			encoding_set: STRING_.same_string (encoding, STRING_.to_upper (an_encoding))
		end

	set_default_byte_order_mark (an_byte_order_mark_required_value: BOOLEAN) is
			-- Set `byte_order_mark_required'.
		do
			byte_order_mark_required := an_byte_order_mark_required_value
		ensure
			byte_order_mark_required_set: byte_order_mark_required = an_byte_order_mark_required_value
		end

	set_default_escape_uri_attributes (an_escape_uri_attributes_value: BOOLEAN) is
			-- Set `escape_uri_attributes'.
		do
			escape_uri_attributes := an_escape_uri_attributes_value
		ensure
			escape_uri_attributes_set: escape_uri_attributes = an_escape_uri_attributes_value
		end

	set_default_include_content_type (an_include_content_type_value: BOOLEAN) is
			-- Set `include_content_type'.
		do
			include_content_type := an_include_content_type_value
		ensure
			include_content_type_set: include_content_type = an_include_content_type_value
		end

feature {NONE} -- Implementation

	string_property_map: DS_HASH_TABLE [STRING, STRING]
			-- Map of property names to string values

	boolean_property_map: DS_HASH_TABLE [BOOLEAN, STRING]
			-- Map of property names to boolean values

	precedence_property_map: DS_HASH_TABLE [INTEGER, STRING]
			-- Map of property names to import precedences

	-- Defaults which differ according to `method':

	default_indent: BOOLEAN
			-- Should the transformer add additional whitespace?

	default_version: STRING
			-- Text of version attribute on xml declaration

	default_media_type: STRING
			-- MIME type to be written

	default_character_representation: STRING
			-- How should characters be represented (a gexslt extension)?

	set_standard_property (a_local_name, a_value: STRING; a_namespace_resolver: XM_XPATH_NAMESPACE_RESOLVER) is
			-- Set the standard XSLT property `a_local_name'.
		require
			local_name_not_void: a_local_name /= Void
			value_not_void: a_value /= Void
			namespace_resolver_not_void: a_namespace_resolver /= Void
			no_previous_error: not is_error
		do
			if STRING_.same_string (a_local_name, Method_attribute) then
				set_method (a_local_name, 1000000)
			elseif STRING_.same_string (a_local_name, Version_attribute) or else STRING_.same_string (a_local_name, Output_version_attribute)then
				set_version (a_value, 1000000)
			elseif STRING_.same_string (a_local_name, Indent_attribute) then
				set_yes_no_property (Indent_attribute, a_value)
				if not is_error then set_indent (last_yes_no_value, 1000000) end
			elseif STRING_.same_string (a_local_name, Encoding_attribute) then
				set_encoding (a_value, 1000000)
			elseif STRING_.same_string (a_local_name, Media_type_attribute) then
				set_media_type (a_value, 1000000)
			elseif STRING_.same_string (a_local_name, Doctype_system_attribute) then
				set_doctype_system (a_value, 1000000)
			elseif STRING_.same_string (a_local_name, Doctype_public_attribute) then
				set_doctype_public (a_value, 1000000)
			elseif STRING_.same_string (a_local_name, Byte_order_mark_attribute) then
				set_yes_no_property (Byte_order_mark_attribute, a_value)
				if not is_error then set_byte_order_mark_required (last_yes_no_value, 1000000) end
			elseif STRING_.same_string (a_local_name, Omit_xml_declaration_attribute) then
				set_yes_no_property (Omit_xml_declaration_attribute, a_value)
				if not is_error then set_omit_xml_declaration (last_yes_no_value, 1000000) end
			elseif STRING_.same_string (a_local_name, Standalone_attribute) then
				if STRING_.same_string (a_value, "yes") or else
					STRING_.same_string (a_value, "no") or else
					STRING_.same_string (a_value, "omit") then
					set_standalone (a_value, 1000000)
				else
					set_general_error (STRING_.concat ("Value for standalone attribute on xsl:result-document must be 'yes' or 'no' or 'omit'. Found: ", a_value))
				end
			elseif STRING_.same_string (a_local_name, Cdata_section_elements_attribute) then
				validate_cdata_sections (a_value, a_namespace_resolver)
				if cdata_validation_error_message /= Void then
					set_general_error (cdata_validation_error_message)
				else
					set_cdata_sections (cdata_section_expanded_names)
				end
			elseif STRING_.same_string (a_local_name, Undeclare_namespaces_attribute) then
				set_yes_no_property (Undeclare_namespaces_attribute, a_value)
				if not is_error then set_undeclare_namespaces (last_yes_no_value, 1000000) end
			elseif STRING_.same_string (a_local_name, Include_content_type_attribute) then
				set_yes_no_property (Include_content_type_attribute, a_value)
				if not is_error then set_include_content_type (last_yes_no_value, 1000000) end
			elseif STRING_.same_string (a_local_name, Escape_uri_attributes_attribute) then
				set_yes_no_property (Escape_uri_attributes_attribute, a_value)
				if not is_error then set_include_content_type (last_yes_no_value, 1000000) end					
			end
		ensure
			error_message_set: is_error implies error_message /= Void
		end

	set_gexslt_property (a_local_name, a_value: STRING) is
			-- Set the gexslt extension property `a_local_name'.
		require
			local_name_not_void: a_local_name /= Void
			value_not_void: a_value /= Void
			no_previous_error: not is_error
		local
			a_boolean: BOOLEAN
		do
			if STRING_.same_string (a_local_name, Gexslt_character_representation_name) then
				if is_valid_character_representation (a_value) then
					set_character_representation (a_value, 1000000)
				end
			elseif STRING_.same_string (a_local_name, Gexslt_indent_spaces_name) then
				if a_value.is_integer and then a_value.to_integer > 0 then
					set_indent_spaces (a_value.to_integer, 1000000)
				end
			end
		ensure
			no_error: not is_error
		end

	last_yes_no_value: BOOLEAN
			-- Last value set by `set_yes_no_property'
	
	set_yes_no_property (a_name, a_value: STRING) is
			-- Interpret `a_value' as a boolean then set `a_name'.
		require
			name_not_void: a_name /= Void
			value_not_void: a_value /= Void
			no_previous_error: not is_error
		local
			a_message: STRING
		do
			if STRING_.same_string (a_value, "yes") then
				last_yes_no_value	 := True
			elseif STRING_.same_string (a_value, "no") then
				last_yes_no_value	:= False
			else
				a_message := STRING_.concat ("Value for ", a_name)
				a_message := STRING_.appended_string (a_message, " must be 'yes' or 'no'. Found: ")
				set_general_error (STRING_.appended_string (a_message, a_value))
			end
		ensure
			value_set_or_error: not is_error implies True -- `last_yes_no_value' correctly set
		end
			
invariant

	extension_attributes_not_void: extension_attributes /= Void
	cdata_section_elements_not_void: cdata_section_elements /= Void
	standalone_valid: standalone /= Void implies standalone.is_equal ("yes") or else standalone.is_equal ("no")
	default_media_type_not_void: default_media_type /= Void
	used_character_maps_not_void: used_character_maps /= Void
	default_version_not_void: default_version /= Void
	encoding_not_void: encoding /= Void
	default_character_representation: default_character_representation /= Void
	valid_method_not_void: method /= Void
	string_property_map_not_void: string_property_map /= Void
	boolean_property_map_not_void: boolean_property_map /= Void
	precedence_property_map_not_void: precedence_property_map /= Void
	unique_property_names: True -- forall (a) string_property_map.has (a) implies not boolean_property_map.has (a) and vice-versa
	duplication_error: is_duplication_error implies is_error and then duplicate_attribute_name /= Void and then error_message = Void
	other_error: is_error and not is_duplication_error implies duplicate_attribute_name = Void and then error_message /= Void
	no_error: not is_error implies duplicate_attribute_name = Void and then error_message = Void

end

