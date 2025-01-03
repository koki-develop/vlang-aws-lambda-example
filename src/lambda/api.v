module lambda

import os
import json
import net.http

@[noinit]
struct Api {
	runtime_api string
}

fn Api.new() !Api {
	runtime_api := os.getenv('AWS_LAMBDA_RUNTIME_API')
	if runtime_api == '' {
		return error('AWS_LAMBDA_RUNTIME_API is not set')
	}

	return Api{runtime_api}
}

// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-next
fn (api Api) next() !http.Response {
	// get the next request
	endpoint := 'http://${api.runtime_api}/2018-06-01/runtime/invocation/next'
	response := http.get(endpoint)!

	// check if the response is ok
	if response.status() != .ok {
		return error('failed to get next request with status: ${response.status()}')
	}

	return response
}

// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-response
fn (api Api) success(request_id string, data string) ! {
	// send the response
	endpoint := 'http://${api.runtime_api}/2018-06-01/runtime/invocation/${request_id}/response'
	response := http.post(endpoint, data)!

	// check if the response is ok
	if response.status() != .accepted {
		return error('failed to send success response with status: ${response.status()}')
	}
}

// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-invokeerror
fn (api Api) failure(request_id string, err IError) ! {
	// send the error
	endpoint := 'http://${api.runtime_api}/2018-06-01/runtime/invocation/${request_id}/error'
	body := json.encode({
		'errorMessage': err.msg()
		'errorType':    err.type_name()
	})
	response := http.post(endpoint, body)!

	// check if the response is ok
	if response.status() != .accepted {
		return error('failed to send failure response with status: ${response.status()}')
	}
}
