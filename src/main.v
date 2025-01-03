module main

import json
import lambda

struct Input {
	success bool @[json: 'success']
}

fn main() {
	lambda.start(handler)!
}

fn handler(ctx lambda.Context, event string) !string {
	input := json.decode(Input, event)!

	// Print the input and context
	println('input: ${input}')
	println('ctx: ${ctx}')
	flush_stdout()

	if input.success {
		return json.encode({
			'success': true
		})
	} else {
		return error('failed')
	}
}
