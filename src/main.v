module main

import json
import lambda

struct Input {
	success bool @[json: 'success']
}

fn main() {
	lambda.start(handler)!
}

fn handler(event string) !string {
	input := json.decode(Input, event)!
	println('input: ${input}')
	flush_stdout()

	if input.success {
		return json.encode({
			'success': true
		})
	} else {
		return error('failed')
	}
}
