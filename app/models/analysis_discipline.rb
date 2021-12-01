# frozen_string_literal: true

class AnalysisDiscipline < ApplicationRecord

  # When it is a copy no need to report connections as 
  # they are supposed to be handled properly in the original analysis
  before_save :report_connections!, unless: :copy_inprogress?
  before_destroy :detach_analysis!

  belongs_to :discipline
  belongs_to :analysis

  class AlreadyDefinedError < StandardError; end

  def copy_inprogress?
    # copy is detected by checking that discipline is a new record.
    # When created due to sub analysis attachment the discipline
    # is already saved in database
    discipline.new_record?
  end

private

  # When saving analysis_discipline we ensure we propagate sub driver's
  # connections to parent analysis.
  def report_connections!
    unless analysis&.new_record?
      disc = discipline
      innermda = analysis
      outermda = discipline.analysis
      # Rails.logger.info ">>>>>>>>>>>>>>>>>>> ATTACH SUBANALYSIS #{innermda.name}"
      # create super disciplines variables last
      disc.create_variables_from_sub_analysis

      # Rails.logger.info "OUTER DRIVER VARS = #{outermda.driver.variables.map { |v| [v.name, v.io_mode] }}"
      # should add to the driver if not connected by other disciplines, remove connection from driver
      innermda.driver.output_variables.each do |var|
        # Rails.logger.info "CHECK #{var.name}"
        present = outermda.disciplines.joins(:variables).where(variables: { name: var.name, io_mode: WhatsOpt::Variable::OUT })
        vattr = var.attributes.except("name", "id", "discipline_id", "created_at", "updated_at")
        if present.blank?
          # Rails.logger.info "1+++++++++++++ ADD TO DRIVER #{outermda.name} #{var.name} #{var.io_mode}"
          outermda.driver.variables.where(name: var.name).first_or_create!(vattr)
        else
          # Rails.logger.info "------- #{var.name} #{var.io_mode} ALREADY PRESENT in #{present.map { |d| d.name }}"
          vattr["io_mode"] = WhatsOpt::Variable::IN
          outermda.driver.variables.where(name: var.name).first_or_create(vattr)
        end
      end

      # Rails.logger.info "OUTER DRIVER VARS = #{outermda.driver.variables.map { |v| [v.name, v.io_mode] }}"

      # should add to the driver if not connected by other disciplines
      innermda.driver.input_variables.each do |var|
        # Rails.logger.info "EXISTENCE #{var.name}"
        producer_count = outermda.disciplines.nodes.joins(:variables).where(variables: { name: var.name, io_mode: WhatsOpt::Variable::OUT }).count
        # p "#{var.name} #{producer_count}"
        unless producer_count==1 # produced only by sub_analysis
          raise AlreadyDefinedError, "Variable #{var.name} already defined, present in analysis and sub_analysis to be added. \n
          You must remove either one or the other before attaching the sub_analysis."
        end

        existing = outermda.driver.variables.where(name: var.name, io_mode: WhatsOpt::Variable::OUT).first
        if existing
          # Rails.logger.info "REMOVE EXISTING SOURCE FROM DRIVER"
          existing.destroy
        else
          # Rails.logger.info "#{var.name} #{var.io_mode} do not exist in driver"
        end
        present = outermda.disciplines.nodes.joins(:variables).where(variables: { name: var.name, io_mode: WhatsOpt::Variable::IN })
        if present.blank?
          vattr = var.attributes.except("name", "io_mode", "id", "discipline_id", "created_at", "updated_at")
          # Rails.logger.info "2+++++++++++++ ADD TO DRIVER #{outermda.name} #{var.name} #{var.io_mode}"
        else
          # Rails.logger.info "........ #{var.name} #{var.io_mode} ALREADY PRESENT in #{present.map { |d| d.name }}"
        end
        outermda.driver.variables.where(name: var.name).first_or_create!(vattr)
      end

      outermda.save!
    end
  end

  # When analysis_discipline is destroyed we manage analysis ancestry
  # by nullifying the parent and make it root again. 
  def detach_analysis!
    analysis.update!(parent: nil)
  end
end
