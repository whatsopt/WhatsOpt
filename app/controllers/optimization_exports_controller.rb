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
        redirect_to optimization_path(optim), notice: "There isn't a log file"
      end
    elsif format == "csv"
      attributes = %w{kind config inputs outputs}
      content = CSV.generate(headers: true) do |csv|
        csv << attributes
        csv << attributes.map{ |attr| optim.send(attr) }
      end
      send_data content, filename: "optim_#{optim_id}.csv"
    end
  end
end
