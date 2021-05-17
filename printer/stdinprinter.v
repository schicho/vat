module printer

import os
import vaterror

struct StdinPrinter {}

pub fn new_stdin_printer() &StdinPrinter {
	r := &StdinPrinter{}
	return r
}

pub fn (sp StdinPrinter) print() {
	mut stdout := os.stdout()
	file := os.stdin()

	// read_bytes_into requires the buffer's length to be greater than 0.
	// Also set cap to buf_size so there are no reallocations.
	mut buf := []byte{len: buf_size, cap: buf_size}

	for {
		// This reads and blocks until the buffer is full or EOF.
		nbytes := file.read_bytes_into_newline(mut buf) or {
			vaterror.fatalln_file_error(file.str(), .cannot_read)
			0
		}
		if nbytes == 0 {
			break
		}
		stdout.write(buf[..nbytes]) or { vaterror.fatalln_file_error(stdout.str(), .cannot_write) }
	}
}
