module lambda

import os
import strconv

@[noinit]
pub struct Context {
pub:
	request_id           string
	function_name        string
	function_memory_size int
	function_version     string
	log_group_name       string
	log_stream_name      string
}

fn Context.new(request_id string) Context {
	return Context{
		request_id:           request_id
		function_name:        os.getenv('AWS_LAMBDA_FUNCTION_NAME')
		function_memory_size: strconv.atoi(os.getenv('AWS_LAMBDA_FUNCTION_MEMORY_SIZE')) or { 0 }
		function_version:     os.getenv('AWS_LAMBDA_FUNCTION_VERSION')
		log_group_name:       os.getenv('AWS_LAMBDA_LOG_GROUP_NAME')
		log_stream_name:      os.getenv('AWS_LAMBDA_LOG_STREAM_NAME')
	}
}
