module printer

import os
import vaterror

struct FilePrinter {
	filepath string
	filesize u64
}

pub fn new_file_printer(filepath string) &FilePrinter {
	r := &FilePrinter{filepath, os.file_size(filepath)}
	return r
}

pub fn (fp FilePrinter) print() {
	mut stdout := os.stdout()

	file := os.open_file(fp.filepath, 'rb') or {
		vaterror.fatalln_file_error(fp.filepath, .permission_denied)
		exit(1)
	}

	// read_bytes_into requires the buffer's length to be greater than 0.
	// Also set cap to buf_size so there are no reallocations.
	mut buf := []byte{len: buf_size, cap: buf_size}

	for pos := u64(0); pos < fp.filesize; pos += buf_size {
		nbytes := file.read_bytes_into(pos, mut buf) or {
			vaterror.fatalln_file_error(file.str(), .cannot_read)
			exit(1)
		}
		stdout.write(buf[..nbytes]) or { vaterror.fatalln_file_error(stdout.str(), .cannot_write) }
	}
}
