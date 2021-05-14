module vaterror

const (
	identifier            = 'vat'

	colon                 = ': '

	not_exists_str        = 'No such file or directory'

	is_directory_str      = 'Is a directory'

	cannot_read_str       = 'Cannot read file'

	cannot_write_str      = 'Cannot write to file'

	permission_denied_str = 'Permission denied'
)

pub enum FileError {
	not_exists
	is_directory
	cannot_read
	cannot_write
	permission_denied
}

pub fn fatalln_file_error(filename string, error FileError) {
	err_msg := vaterror.identifier + vaterror.colon + filename + vaterror.colon
	match error {
		.not_exists { eprintln(err_msg + vaterror.not_exists_str) }
		.is_directory { eprintln(err_msg + vaterror.is_directory_str) }
		.cannot_read { eprintln(err_msg + vaterror.cannot_read_str) }
		.cannot_write { eprintln(err_msg + vaterror.cannot_write_str) }
		.permission_denied { eprintln(err_msg + vaterror.permission_denied_str) }
		// else { eprintlnn(err_msg + 'Unknown error occured') }
	}
	exit(1)
}

pub fn fatalln_msg(msg string) {
	eprintln(vaterror.identifier + msg)
	exit(1)
}
