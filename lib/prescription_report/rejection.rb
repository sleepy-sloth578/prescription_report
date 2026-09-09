# frozen_string_literal: true

module PrescriptionReport
  # A discarded line: the reason it was rejected and where it came from
  Rejection = Data.define(:source_line, :reason, :detail) do
    def to_s
      "line #{source_line}: #{reason} (#{detail})"
    end
  end
end
