module ResponseHandler
  extend ActiveSupport::Concern

  def json_response(options = {}, status = :internal_server_error)
    render json: JsonResponse.new(options), status:
  end

  def render_error_response(error, status = :unprocessable_entity, message = "")
    json_response({
                    success: false,
                    message:,
                    errors: error
                  }, status)
  end

  def render_success_response(data: {}, message: "", status: :ok)
    json_response({
                    success: true,
                    message:,
                    data:
                  }, status)
  end
end
