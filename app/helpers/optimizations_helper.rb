# frozen_string_literal: true

module OptimizationsHelper
  def status_text(status)
    status_text = {
      Optimization::OPTIMIZATION_ERROR => "Optimization_Error",
      Optimization::PENDING => "Pending",
      Optimization::VALID_POINT => "Valid Point",
      Optimization::INVALID_POINT => "Invalid Point",
      Optimization::RUNTIME_ERROR => "Runtime Error",
      Optimization::SOLUTION_REACHED => "Solution Reached",
      Optimization::RUNNING => "Running"
    }
    status_text[status] || "Empty"
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

  def optim_history(optim)
    optim.x ? "#{optim.x.length} points" : "empty"
  end

  def optim_input_dim(optim)
    if !optim.xtypes.blank?
      optim.xtypes.size
    elsif !optim.xlimits.blank?
      optim.xlimits.size
    else
      "?"
    end
  end

  def optim_cstrs_dim(optim)
    if optim.cstr_specs
      optim.cstr_specs.size
    else
      "0"
    end
  end

  def nb_points(input)
    (input.empty? || input["x"].nil?) ? "0" : input["x"].length
  end
end
