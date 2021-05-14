module main

import printer
import vaterror
import os
import cli

const stdin_abbrev = '-'

fn main() {
	mut app := cli.Command{
		name: 'vat'
		description: 'vat is a simple clone of cat, written in V instead of C.\n' +
			'Written by Sebastian Schicho 2021.'
		usage: '\n\nJust like GNU cat, but without the flags.\n' +
			'It does only concatenate to stdout.\n' +
			'Also (unsurprisingly) - this implementation is slower.'
		version: '0.1'
		execute: fn (cmd cli.Command) ? {
			run_vat(cmd.args)
			return
		}
		flags: [
			cli.Flag{
				flag: cli.FlagType.bool
				name: 'help'
				abbrev: 'h'
			},
		]
	}
	app.setup()
	app.parse(os.args)
}

fn run_vat(args []string) {
	if args.len == 0 {
		sp := printer.new_stdin_printer()
		sp.print()
	} else {
		mut printers := []printer.Printer{}
		for arg in args {
			// '-' is the abbreviation for reading from stdin,
			// allowing e.g. to cat a file, followed by stdin.
			if arg == stdin_abbrev {
				printers << printer.new_stdin_printer()
			} else if !os.exists(arg) {
				vaterror.fatalln_file_error(arg, .not_exists)
			} else if os.is_dir(arg) {
				vaterror.fatalln_file_error(arg, .is_directory)
			} else {
				printers << printer.new_file_printer(arg)
			}
		}
		for printer in printers {
			printer.print()
		}
	}
}
