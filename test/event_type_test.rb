# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/prescription_report"

describe PrescriptionReport::EventType do
  let(:event_type) { PrescriptionReport::EventType }

  def test_parses_each_name
    assert_equal event_type::CREATED,  event_type.parse("created")
    assert_equal event_type::FILLED,   event_type.parse("filled")
    assert_equal event_type::RETURNED, event_type.parse("returned")
  end

  def test_every_member_of_all_parses
    event_type::ALL.each do |type|
      assert_equal type, event_type.parse(type.to_s)
    end
  end

  def test_is_case_insensitive
    assert_equal event_type::CREATED,  event_type.parse("CREATED")
    assert_equal event_type::FILLED,   event_type.parse("Filled")
    assert_equal event_type::RETURNED, event_type.parse("ReTuRnEd")
  end

  def test_strips_surrounding_whitespace
    assert_equal event_type::CREATED, event_type.parse("  created")
    assert_equal event_type::FILLED,  event_type.parse("filled\t")
    assert_equal event_type::CREATED, event_type.parse("\ncreated \n")
  end

  def test_unknown_word_raises_parse_error
    assert_raises(PrescriptionReport::ParseError) { event_type.parse("expired") }
  end

  def test_empty_and_nil_raise
    assert_raises(PrescriptionReport::ParseError) { event_type.parse("") }
    assert_raises(PrescriptionReport::ParseError) { event_type.parse("   ") }
    assert_raises(PrescriptionReport::ParseError) { event_type.parse(nil) }
  end
end
