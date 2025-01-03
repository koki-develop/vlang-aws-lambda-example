module lambda

pub type Handler = fn (ctx Context, event string) !string
