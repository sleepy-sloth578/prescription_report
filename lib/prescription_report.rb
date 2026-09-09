# frozen_string_literal: true

module PrescriptionReport
  # Base class for every error this library raises, so callers can rescue
  # PrescriptionReport::Error and catch all of them.
  class Error < StandardError; end

  # Raised when input cannot be parsed into a value the rest of the library trusts.
  class ParseError < Error; end

  FILL_REVENUE_CENTS = 500
  RETURN_DELTA_CENTS = -600

  def self.format_money(cents)
    sign = cents.negative? ? "-" : ""
    magnitude = cents.abs

    if (magnitude % 100).zero?
      "#{sign}$#{magnitude / 100}"
    else
      format("%s$%d.%02d", sign, magnitude / 100, magnitude % 100)
    end
  end
end

require_relative "prescription_report/event_type"
require_relative "prescription_report/event"
require_relative "prescription_report/rejection"
require_relative "prescription_report/patient_summary"
