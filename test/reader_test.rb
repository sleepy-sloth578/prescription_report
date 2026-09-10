# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::Reader do
  let(:reader)     { PrescriptionReport::Reader }
  let(:event)      { PrescriptionReport::Event }
  let(:rejection)  { PrescriptionReport::Rejection }
  let(:event_type) { PrescriptionReport::EventType }

  def parse(input)
    results = []
    reader.new(input).each { |result| results << result } # rubocop:disable Style/MapIntoArray
    results
  end

  def test_a_well_formed_line_becomes_an_event
    results = parse("Mark B created\n")

    assert_equal 1, results.size

    parsed = results.first

    assert_instance_of event, parsed
    assert_equal "Mark",              parsed.patient
    assert_equal "B",                 parsed.drug
    assert_equal event_type::CREATED, parsed.type
    assert_equal 1,                   parsed.source_line
  end

  def test_each_valid_line_yields_one_event_in_order
    results = parse("Mark B created\nMark B filled\nMark B returned\n")

    assert_equal 3, results.size
    assert(results.all?(event))
    assert_equal %i[created filled returned], results.map(&:type)
  end

  def test_multiple_spaces_and_tabs_are_one_separator
    results = parse("Mark   B\tcreated\n")

    assert_instance_of event, results.first
    assert_equal "Mark", results.first.patient
    assert_equal "B",    results.first.drug
  end

  def test_leading_and_trailing_whitespace_is_ignored
    results = parse("   Mark B created   \n")

    assert_instance_of event, results.first
    assert_equal "created", results.first.type.to_s
  end

  def test_blank_lines_are_skipped_and_yield_nothing
    assert_empty parse("\n\n   \n\t\n")
  end

  def test_blank_lines_between_records_do_not_break_line_numbers
    results = parse("Mark B created\n\nMark B filled\n")

    assert_equal 2, results.size
    assert_equal 1, results[0].source_line
    assert_equal 3, results[1].source_line
  end

  def test_too_few_fields_is_rejected
    result = parse("Mark B\n").first

    assert_instance_of rejection, result
    assert_match(/expected 3 fields, got 2/, result.detail)
    assert_equal 1, result.source_line
  end

  def test_unknown_event_type_is_rejected_via_the_rescue_path
    result = parse("Mark B expired\n").first

    assert_instance_of rejection, result
    assert_match(/unknown event type/i, result.detail)
  end

  def test_a_bad_line_does_not_halt_the_stream
    results = parse("Mark B created\nMark B oops\nMark B filled\n")

    assert_equal 3, results.size
    assert_instance_of event,     results[0]
    assert_instance_of rejection, results[1]
    assert_instance_of event,     results[2]
  end

  def test_last_line_without_a_trailing_newline_is_still_read
    results = parse("Mark B created\nMark B filled")

    assert_equal 2, results.size
    assert_equal "filled", results.last.type.to_s
  end
end
