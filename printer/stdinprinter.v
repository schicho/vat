module printer

import os
import vaterror

// These includes are needed to call C code checking if a interactive shell
// or a pipe is being used on stdin.
#include <stdio.h>
$if linux || macos {
	#include <unistd.h>
} $else {
	#include <io.h>
}

struct StdinPrinter {}

pub fn new_stdin_printer() &StdinPrinter {
	r := &StdinPrinter{}
	return r
}

// This is slow and can use a lot of memory when the input string is long.
// Hence this is only used, when read from an interactive shell with direct
// user input, where faster speed and lot's of memory consumption is no issue.
fn (sp StdinPrinter) print_interactive() {
	mut buf := ''
	for {
		buf = os.get_raw_line()
		if buf.len == 0 {
			break
		}
		print(buf)
	}
}

pub fn (sp StdinPrinter) print() {
	// First detect if the user calls an interactive shell or pipes data into
	// stdin. If a pipe is being used, we can read more efficently from stdin.
	mut is_interactive_shell := -1

	$if linux || macos {
		is_interactive_shell = C.isatty(C.fileno(C.stdin))
	} $else {
		is_interactive_shell = C._isatty(C._fileno(C.stdin))
	}

	match is_interactive_shell {
		-1 {
			eprintln('Could not detect if a pipe is being used. Falling back to interactive shell. This might be slow')
			sp.print_interactive()
			return
		}
		1 {
			sp.print_interactive()
			return
		}
		else {
			// Continue. Read from stdin fast.
		}
	}

	mut stdout := os.stdout()
	file := os.stdin()

	// read_bytes_into requires the buffer's length to be greater than 0.
	// Also set cap to buf_size so there are no reallocations.
	mut buf := []byte{len: buf_size, cap: buf_size}
	mut pos := u64(0)

	for {
		// This reads and blocks until the buffer is full or EOF.
		nbytes := file.read_bytes_into(pos, mut buf) or {
			vaterror.fatalln_file_error(file.str(), .cannot_read)
			exit(1)
		}
		if nbytes == 0 {
			break
		}
		stdout.write(buf[..nbytes]) or { vaterror.fatalln_file_error(stdout.str(), .cannot_write) }
		pos += u64(nbytes)
	}
}
