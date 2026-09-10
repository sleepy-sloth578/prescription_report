# frozen_string_literal: true

module PrescriptionReport
  # One (patient, drug) prescription. Counts fills and returns applied to it
  class Prescription
    FILL_REVENUE_CENTS = 500
    RETURN_DELTA_CENTS = -600

    def initialize
      @fills   = 0
      @returns = 0
    end

    def fill
      @fills += 1
    end

    def return_fill
      @returns += 1
    end

    def returnable?
      outstanding_fills.positive?
    end

    def outstanding_fills
      @fills - @returns
    end

    def income_cents
      (@fills * FILL_REVENUE_CENTS) + (@returns * RETURN_DELTA_CENTS)
    end
  end
end
