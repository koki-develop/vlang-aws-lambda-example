module lambda

pub fn start(handler Handler) ! {
	api := Api.new()!

	for {
		// Get the next request
		next_request := api.next()!

		// Create the context
		ctx := Context.new(next_request)!

		// Handle the request
		response := handler(ctx, next_request.body) or {
			api.failure(ctx.request_id, err)!
			continue
		}

		// Send the success response
		api.success(ctx.request_id, response)!
	}
}
