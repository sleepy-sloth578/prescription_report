# frozen_string_literal: true

module PrescriptionReport
  Event = Data.define(:patient, :drug, :type, :source_line) do
    # A prescription is identified by (patient, drug)
    def key
      [patient, drug].freeze
    end

    def to_s
      "#{patient}/#{drug} #{type}"
    end
  end
end
