# frozen_string_literal: true

module PrescriptionReport
  # Base class for every error this library raises, so callers can rescue
  # PrescriptionReport::Error and catch all of them.
  class Error < StandardError; end

  # Raised when input cannot be parsed into a value the rest of the library trusts.
  class ParseError < Error; end
end

require_relative "prescription_report/event_type"
require_relative "prescription_report/event"
