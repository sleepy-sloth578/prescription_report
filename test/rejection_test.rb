# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::Rejection do
  let(:rejection) { PrescriptionReport::Rejection }

  def build(**overrides)
    defaults = { source_line: 3, reason: "unknown event type", detail: "expired" }
    rejection.new(**defaults, **overrides)
  end

  def test_exposes_each_field_it_was_built_with
    built = build(source_line: 12, reason: "malformed row", detail: "too few columns")

    assert_equal 12,                built.source_line
    assert_equal "malformed row",   built.reason
    assert_equal "too few columns", built.detail
  end

  def test_two_rejections_with_the_same_fields_are_equal
    assert_equal build, build
    refute_equal build, build(source_line: 99)
  end
end
