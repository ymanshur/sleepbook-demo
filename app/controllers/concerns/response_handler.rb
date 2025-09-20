module ResponseHandler
  extend ActiveSupport::Concern

  def render_error_response(error, status = :unprocessable_content, message = "")
    json_response({
                    success: false,
                    message:,
                    errors: error.is_a?(String) ? [ error.upcase_first ] : error
                  }, status)
  end

  def render_success_response(data: {}, message: "", status: :ok, meta: {})
    json_response({
                    success: true,
                    message:,
                    data:,
                    meta:
                  }, status)
  end

  private

  def json_response(options = {}, status = :internal_server_error)
    render json: JsonResponse.new(options), status:
  end
end
