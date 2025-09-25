class ApplicationController < ActionController::API
  include ResponseHandler
  include ExceptionHandler
  include PaginationHandler
  include DateRangeHandler

  def catch404
    raise ActionController::RoutingError, "Resource not found: #{request.path}"
  end
end
