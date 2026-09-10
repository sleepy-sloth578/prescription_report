# frozen_string_literal: true

module PrescriptionReport
  module Money
    def self.format(cents)
      sign = cents.negative? ? "-" : ""
      abs_cents = cents.abs

      if (abs_cents % 100).zero?
        "#{sign}$#{abs_cents / 100}"
      else
        Kernel.format("%s$%d.%02d", sign, abs_cents / 100, abs_cents % 100)
      end
    end
  end
end
