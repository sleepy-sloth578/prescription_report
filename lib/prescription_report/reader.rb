# frozen_string_literal: true

module PrescriptionReport
  # Streams events out of a whitespace-separated source, one line at a time.
  class Reader
    FIELD_COUNT = 3

    # Seperates fields either by single space, multi or tab aligned
    SEPARATOR = /\s+/

    def initialize(io)
      @io = io
    end

    # Always call with a block; this is an internal streaming iterator
    def each
      line_number = 0
      @io.each_line do |line|
        line_number += 1
        stripped = line.strip
        next if stripped.empty?

        yield parse_line(stripped, line_number)
      end
    end

    private

    def parse_line(line, line_number)
      fields = line.split(SEPARATOR)

      unless valid_fields?(fields)
        return Rejection.new(
          source_line: line_number,
          reason: "malformed line",
          detail: "expected #{FIELD_COUNT} fields, got #{fields.size}: #{line.inspect}"
        )
      end

      patient, drug, event = fields

      Event.new(
        patient: patient,
        drug: drug,
        type: EventType.parse(event),
        source_line: line_number
      )
    rescue ParseError => e
      Rejection.new(source_line: line_number, reason: "malformed line", detail: e.message)
    end

    def valid_fields?(fields)
      fields.size == FIELD_COUNT
    end
  end
end
