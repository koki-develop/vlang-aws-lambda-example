module lambda

import net.http
import os
import json

type Handler = fn (Context, string) !string

const runtime_api = os.getenv('AWS_LAMBDA_RUNTIME_API')

pub fn start(handler Handler) ! {
	if runtime_api == '' {
		return error('AWS_LAMBDA_RUNTIME_API is not set')
	}

	for {
		// Get the next request
		next_request := next()!

		// Create the context
		ctx := Context.new(next_request.header.get_custom('lambda-runtime-aws-request-id')!)

		// Handle the request
		response := handler(ctx, next_request.body) or {
			failure(ctx.request_id, err)!
			continue
		}

		// Send the success response
		success(ctx.request_id, response)!
	}
}

// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-next
fn next() !http.Response {
	endpoint := 'http://${runtime_api}/2018-06-01/runtime/invocation/next'
	response := http.get(endpoint)!
	if response.status() != .ok {
		return error(response.body)
	}

	return response
}

// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-response
fn success(request_id string, data string) ! {
	endpoint := 'http://${runtime_api}/2018-06-01/runtime/invocation/${request_id}/response'
	response := http.post(endpoint, data)!
	if response.status() != .accepted {
		return error(response.body)
	}
}

// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-invokeerror
fn failure(request_id string, err IError) ! {
	endpoint := 'http://${runtime_api}/2018-06-01/runtime/invocation/${request_id}/error'
	body := json.encode({
		'errorMessage': err.msg()
		'errorType':    err.type_name()
	})
	response := http.post(endpoint, body)!
	if response.status() != .accepted {
		return error(response.body)
	}
}
