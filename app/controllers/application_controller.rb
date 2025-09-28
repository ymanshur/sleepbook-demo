class ApplicationController < ActionController::API
  include ResponseHandler
  include ExceptionHandler
  include PaginationHandler
  include DateRangeHandler

  DEFAULT_SCOPE_LIMIT = ENV.fetch("DEFAULT_SCOPE_LIMIT", 25).to_i

  def catch404
    raise ActionController::RoutingError, "Resource not found: #{request.path}"
  end
end
