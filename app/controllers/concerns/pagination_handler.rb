module PaginationHandler
  extend ActiveSupport::Concern

  include Pagy::Backend

  def pagination_params
    sanitized_params = params.permit(:page, :limit)
    sanitized_params.to_h.symbolize_keys
  end

  def render_pagy_response(data: {}, message: "", status: :ok, meta: {})
    render_success_response(data:, message:, status:, meta: {
                                                              current_page: meta[:page],
                                                              next_page: meta[:next],
                                                              prev_page: meta[:prev],
                                                              total_pages: meta[:pages],
                                                              total_count: meta[:count]
                                                            }.compact)
  end
end
