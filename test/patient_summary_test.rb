# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::PatientSummary do
  let(:patient_summary) { PrescriptionReport::PatientSummary }

  def build(**overrides)
    defaults = { patient: "Mark", fills: 2, income_cents: 900 }
    patient_summary.new(**defaults, **overrides)
  end

  def test_exposes_each_field
    summary = build(patient: "John", fills: 0, income_cents: -100)

    assert_equal "John", summary.patient
    assert_equal 0,      summary.fills
    assert_equal(-100,   summary.income_cents)
  end

  def test_formats_whole_dollars_without_decimals
    assert_equal "$9", build(income_cents: 900).formatted_income
    assert_equal "$5", build(income_cents: 500).formatted_income
  end

  def test_formats_zero
    assert_equal "$0", build(income_cents: 0).formatted_income
  end

  def test_formats_a_loss_with_sign_outside_the_dollar
    assert_equal "-$1", build(income_cents: -100).formatted_income
  end

  def test_formats_non_whole_dollars_with_two_decimals
    assert_equal "$1.50",  build(income_cents: 150).formatted_income
    assert_equal "-$0.05", build(income_cents: -5).formatted_income
  end

  def test_to_s_matches_the_expected_output_rows
    assert_equal "Mark: 2 fills $9 income",
                 build(patient: "Mark", fills: 2, income_cents: 900).to_s
    assert_equal "John: 0 fills -$1 income",
                 build(patient: "John", fills: 0, income_cents: -100).to_s
    assert_equal "Nick: 0 fills $0 income",
                 build(patient: "Nick", fills: 0, income_cents: 0).to_s
  end
end
