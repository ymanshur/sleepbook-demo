class JsonResponse
  attr_reader :success, :message, :data, :meta, :errors

  def initialize(options = {})
    @success = options[:success]
    @message = options[:message]
    @data = options[:data]
    @meta = options[:meta]
    @errors = options[:errors]
  end

  def as_json(*)
    {
      success:,
      message:,
      data:,
      meta:,
      errors:
    }.compact
  end
end
