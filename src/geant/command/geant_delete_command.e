indexing

	description:

		"Delete commands"

	library:    "Gobo Eiffel Ant"
	author:     "Sven Ehrke <sven.ehrke@sven-ehrke.de>"
	copyright:  "Copyright (c) 2001, Sven Ehrke and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"


class GEANT_DELETE_COMMAND

inherit

	GEANT_COMMAND

creation

	make

feature -- Status report

	is_file_executable: BOOLEAN is
			-- Can command be executed on a file?
		do
			Result := file /= Void and then file.count > 0
		ensure
			file_not_void: Result implies file /= Void
			file_not_empty: Result implies file.count > 0
		end

	is_directory_executable: BOOLEAN is
			-- Can command be executed on a directory?
		do
			Result := directory /= Void and then directory.count > 0
		ensure
			directory_not_void: Result implies directory /= Void
			directory_not_empty: Result implies directory.count > 0
		end

	is_fileset_executable: BOOLEAN is
			-- Can command be executed on a fileset?
		do
			Result := fileset /= Void
		ensure
			fileset_not_void: Result implies fileset /= Void
		end

	is_executable: BOOLEAN is
			-- Can command be executed?
		do
			Result :=
				(is_file_executable and not is_directory_executable and not is_fileset_executable) or
				(not is_file_executable and is_directory_executable and not is_fileset_executable) or
				(not is_file_executable and not is_directory_executable and is_fileset_executable)
		ensure then
			file_xor_directory: Result implies (
				(is_file_executable and not is_directory_executable and not is_fileset_executable) or
				(not is_file_executable and is_directory_executable and not is_fileset_executable) or
				(not is_file_executable and not is_directory_executable and is_fileset_executable))
		end

feature -- Access

	directory: STRING
			-- Directory to delete

	file: STRING
			-- File to delete

	fileset: GEANT_FILESET
		-- Fileset for current command

feature -- Setting

	set_directory (a_directory: like directory) is
			-- Set `directory' to `a_directory'.
		require
			a_directory_not_void: a_directory /= Void
			a_directory_not_empty: a_directory.count > 0
		do
			directory := a_directory
		ensure
			directory_set: directory = a_directory
		end

	set_file (a_file: like file) is
			-- Set `file' to `a_file'.
		require
			a_file_not_void: a_file /= Void
			a_file_not_empty: a_file.count > 0
		do
			file := a_file
		ensure
			file_set: file = a_file
		end

	set_fileset (a_fileset: like fileset) is
			-- Set `fileset' to `a_fileset'.
		require
			a_fileset_not_void: a_fileset /= Void
		do
			fileset := a_fileset
		ensure
			fileset_set: fileset = a_fileset
		end

feature -- Execution

	execute is
			-- Execute command.
		local
			a_name: STRING
		do
			exit_code := 0
			if is_directory_executable then
				a_name := file_system.pathname_from_file_system (directory, unix_file_system)
				project.trace ("  [delete] " + a_name + "%N")
				file_system.recursive_delete_directory (a_name)
				if file_system.directory_exists (a_name) then
					project.log ("  [delete] error: cannot delete directory '" + a_name + "'%N")
					exit_code := 1
				end
			elseif is_file_executable then
				a_name := file_system.pathname_from_file_system (file, unix_file_system)
				project.trace ("  [delete] " + a_name + "%N")
				file_system.delete_file (a_name)
				if file_system.file_exists (a_name) then
					project.log ("geant error: cannot delete file '" + a_name + "'%N")
					exit_code := 1
				end
			else
				check is_fileset_executable: is_fileset_executable end
				from
					fileset.execute
					fileset.filenames.start
				until
					fileset.filenames.after or else exit_code /= 0
				loop
					a_name := file_system.pathname_from_file_system (fileset.filenames.item_for_iteration, unix_file_system)
					project.trace ("  [delete] " + a_name + "%N")
					file_system.delete_file (a_name)
					if file_system.file_exists (a_name) then
						project.log ("geant error: cannot delete file '" + a_name + "'%N")
						exit_code := 1
					end

					fileset.filenames.forth
				end
			end
		end

end -- class GEANT_DELETE_COMMAND

