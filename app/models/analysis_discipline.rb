# frozen_string_literal: true

class AnalysisDiscipline < ApplicationRecord
  before_save :report_connections!

  belongs_to :discipline
  belongs_to :analysis

  def self.build_analysis_discipline(disc, innermda)
    disc.type = :mda
    disc.name = innermda.name
    mda_discipline = disc.build_analysis_discipline
    mda_discipline.analysis = innermda
    innermda.parent = disc.analysis
    mda_discipline
  end

  def save!
    analysis.save!
    discipline.save!
  end

  def report_connections!
    unless analysis&.new_record?
      disc = discipline
      innermda = analysis
      outermda = discipline.analysis
      Rails.logger.info ">>>>>>>>>>>>>>>>>>> ATTACH SUBANALYSIS #{innermda.name}"
      # create super disciplines variables last
      disc.create_variables_from_sub_analysis
      
      Rails.logger.info "OUTER DRIVER VARS = #{outermda.driver.variables.map{|v| [v.name, v.io_mode]}}" 
      # should add to the driver if not connected by other disciplines, remove connection from driver
      innermda.driver.output_variables.each do |var|
        Rails.logger.info "CHECK #{var.name}" 
        present = outermda.disciplines.joins(:variables).where(variables: {name: var.name, io_mode: WhatsOpt::Variable::OUT})
        vattr = var.attributes.except("name", "id", "discipline_id", "created_at", "updated_at")
        if present.blank?
          Rails.logger.info "1+++++++++++++ ADD TO DRIVER #{outermda.name} #{var.name} #{var.io_mode}"
          outermda.driver.variables.where(name: var.name).first_or_create!(vattr)
        else
          Rails.logger.info "------- #{var.name} #{var.io_mode} ALREADY PRESENT in #{present.map{|d| d.name}}"
          vattr["io_mode"] = WhatsOpt::Variable::IN
          outermda.driver.variables.where(name: var.name).first_or_create(vattr)
        end
      end

      Rails.logger.info "OUTER DRIVER VARS = #{outermda.driver.variables.map{|v| [v.name, v.io_mode]}}" 

      # should add to the driver if not connected by other disciplines
      innermda.driver.input_variables.each do |var|
        Rails.logger.info "EXISTENCE #{var.name}" 
        existing = outermda.driver.variables.where(name: var.name, io_mode: WhatsOpt::Variable::OUT).first
        if existing
          Rails.logger.info "REMOVE EXISTING SOURCE FROM DRIVER"
          existing.destroy
        else 
          Rails.logger.info "#{var.name} #{var.io_mode} do not exist in driver"
        end
        present = outermda.disciplines.nodes.joins(:variables).where(variables: {name: var.name, io_mode: WhatsOpt::Variable::IN})
        if present.blank?
          vattr = var.attributes.except("name", "io_mode", "id", "discipline_id", "created_at", "updated_at")
          Rails.logger.info "2+++++++++++++ ADD TO DRIVER #{outermda.name} #{var.name} #{var.io_mode}"
        else
          Rails.logger.info "........ #{var.name} #{var.io_mode} ALREADY PRESENT in #{present.map{|d| d.name}}"
        end
        outermda.driver.variables.where(name: var.name).first_or_create!(vattr)
      end

      outermda.save!
    end
  end

end
