# frozen_string_literal: true

module PrescriptionReport
  class Event
    attr_reader :patient, :drug, :type, :source_line

    def initialize(patient:, drug:, type:, source_line:)
      @patient     = patient
      @drug        = drug
      @type        = type
      @source_line = source_line
    end

    # A prescription is identified by (patient, drug)
    def key
      [patient, drug].freeze
    end

    def to_s
      "#{patient}/#{drug} #{type}"
    end
  end
end
