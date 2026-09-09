# frozen_string_literal: true

module PrescriptionReport
  module EventType
    CREATED = :created
    FILLED = :filled
    RETURNED = :returned

    ALL = [CREATED, FILLED, RETURNED].freeze

    def self.parse(raw)
      normalized = raw.to_s.strip.downcase.to_sym
      return normalized if ALL.include?(normalized)

      raise ParseError, "Unknown event type #{raw.inspect}, expected one of: #{ALL.join(', ')}"
    end
  end
end
