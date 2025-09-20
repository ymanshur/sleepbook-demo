module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    around_action :handle_exceptions
  end

  def handle_exceptions
    yield
  rescue ActionController::RoutingError, ActiveRecord::RecordNotFound => e
    handle_not_found(e.message)
  rescue  ActiveRecord::RecordInvalid => e
    handle_unprocessable_content(e.record.errors.full_messages)
  rescue ActionDispatch::Http::Parameters::ParseError, ActionController::ParameterMissing => e
    handle_bad_request(e.message)
  rescue StandardError => e
    log_exception(e) unless Rails.env.test?

    handle_internal_error(e.message)
  end

  private

  def handle_not_found(error)
    render_error_response(error, :not_found, status(:not_found))
  end

  def handle_unprocessable_content(error)
    render_error_response(error, :unprocessable_content, status(:unprocessable_content))
  end

  def handle_bad_request(error)
    render_error_response(error, :bad_request, status(:bad_request))
  end

  def handle_internal_error(error)
    render_error_response(error, :internal_server_error, status(:internal_server_error))
  end

  def status(status_symbol)
    Rack::Utils::HTTP_STATUS_CODES[Rack::Utils.status_code(status_symbol)]
  end

  def log_exception(e)
    Rails.logger.error "\n\n\n#{e.class} (#{e.message})"

    Rails.logger.error "Caused by: #{e.cause.class} (#{e.cause.message})" if e.cause

    # Log the backtrace for the main exception
    Rails.logger.error "\nInformation for: #{e.class} (#{e.message}):\n"
    e.backtrace.each { |line| Rails.logger.error "#{line}" }

    # Log the backtrace for the caused-by exception
    # Rails.logger.error "\nInformation for cause: #{e.cause.class} (#{e.cause.message}):\n"
    # e.cause.backtrace.each { |line| Rails.logger.error "#{line}" }
  end
end
