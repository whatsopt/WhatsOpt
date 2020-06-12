# frozen_string_literal: true

module Response
  def json_response(object, status=:ok, options={})
    if options[:serializer]
      render json: object, status: status, serializer: options[:serializer]
    elsif options[:each_serializer]
      render json: object, status: status, each_serializer: options[:each_serializer]
    else
      render json: object, status: status
    end
  end
end
