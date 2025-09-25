module DateRangeHandler
  extend ActiveSupport::Concern

  MAX_INTERVAL_SECONDS = ENV.fetch("DEFAULT_SCOPE_LIMIT", 25).to_i.days.to_i

  def date_range_params!
    permitted_params = params.permit(:start, :end)
    parse_date_range!(permitted_params)
  end

  private

  def parse_date_range!(params)
    start_time = nil
    end_time = nil

    # Handle the case where both parameters are present
    if params[:start].present? && params[:end].present?
      start_time = Time.at(params[:start].to_i)
      end_time = Time.at(params[:end].to_i)

      # Validate date order
      raise ActionController::ParameterMissing, "Start date must be before or equal to the end date" if start_time > end_time

      # Validate maximum duration
      raise ActionController::ParameterMissing, "The time range cannot exceed #{MAX_INTERVAL_SECONDS / 1.day} days" if (end_time - start_time) > MAX_INTERVAL_SECONDS

    # Handle the case where only one parameter is present
    elsif params[:start].present?
      start_time = Time.at(params[:start].to_i)
      end_time = start_time + MAX_INTERVAL_SECONDS

    elsif params[:end].present?
      end_time = Time.at(params[:end].to_i)
      start_time = end_time - MAX_INTERVAL_SECONDS
    end

    [ start_time, end_time ]
  rescue ArgumentError, TypeError => e
    raise ActionController::ParameterMissing, "Invalid date format: #{e.message}"
  end
end
