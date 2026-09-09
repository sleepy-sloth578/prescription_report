# frozen_string_literal: true

module PrescriptionReport
  PatientSummary = Data.define(:patient, :fills, :income_cents) do
    def formatted_income
      PrescriptionReport.format_money(income_cents)
    end

    def to_s
      "#{patient}: #{fills} fills #{formatted_income} income"
    end
  end
end
