# frozen_string_literal: true

module OptimizationsHelper

  def status_text(status)
    status_text = {
      Optimization::OPTIMIZATION_ERROR => "Optimization_Error",
      Optimization::PENDING => "Pending",
      Optimization::VALID_POINT => "Valid_Point",
      Optimization::INVALID_POINT => "Invalid_Point",
      Optimization::RUNTIME_ERROR => "Runtime_Error",
      Optimization::SOLUTION_REACHED => "Solution_Reached",
      Optimization::RUNNING => "Running"
    }
    status_text[status] ? status_text[status] : "Empty"
  end

  def status_display(status)
    case status
    when Optimization::VALID_POINT, Optimization::SOLUTION_REACHED
      ["color:#00AA00;", "fas fa-check"]
    when Optimization::PENDING, Optimization::RUNNING 
      ["color:#FFA500;", "fas fa-hourglass"]
    else
      ["color:#CC0000;", "fas fa-times"]
    end
  end

  def nb_points(input)
    if input.empty?
      "empty"
    end
    input["x"].nil? ? "0" : input["x"].length
  end
end
