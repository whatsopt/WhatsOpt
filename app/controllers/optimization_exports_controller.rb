# frozen_string_literal: true

require "csv"

class OptimizationExportsController < ApplicationController
  def new
    optim_id = params[:optimization_id]
    format = params[:format]

    optim = Optimization.find(optim_id)
    authorize optim

    if format == "log"
      path = "#{Rails.root}/log/optimizations/optim_#{optim_id}.log"
      if File.exist?(path)
        send_file(path)
      else
        redirect_to optimization_path(optim), alert: "No log file available!"
      end
    elsif format == "csv"
      content = CSV.generate(col_sep: ";") do |csv|
        unless optim.inputs.empty? || optim.x.nil?
          headers = []
          headers += optim.x[0].map.with_index { |_, i| "x_#{i + 1}" }
          headers += (1..optim.n_obj).map { |i| "obj_#{i}" }
          headers += (1..optim.cstr_specs.size).map { |i| "cstr_#{i}" }
          csv << headers
          optim.x.each_with_index do |x, i|
            csv << x + optim.y[i]
          end
        end
      end
      send_data content, filename: "optim_#{optim_id}.csv"
    elsif format == "result_csv"
      content = CSV.generate(col_sep: ";") do |csv|
        unless optim.inputs.empty? || optim.x.nil?
          headers = []
          headers += optim.x_best[0].map.with_index { |_, i| "x_#{i + 1}" }
          headers += (1..optim.n_obj).map { |i| "obj_#{i}" }
          csv << headers
          optim.x_best.each_with_index do |x_best, i|
            csv << x_best + optim.y_best[i]
          end
        end
      end
      send_data content, filename: "optim_#{optim_id}.csv"
    end
  end
end
