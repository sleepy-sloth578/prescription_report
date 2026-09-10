# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::Money do
  let(:money) { PrescriptionReport::Money }

  def test_formats_whole_dollars_without_decimals
    assert_equal "$9",  money.format(900)
    assert_equal "$5",  money.format(500)
    assert_equal "$42", money.format(4200)
  end

  def test_formats_zero_as_plain_dollar
    assert_equal "$0", money.format(0)
  end

  def test_formats_non_whole_dollars_with_two_decimals
    assert_equal "$1.50", money.format(150)
    assert_equal "$9.99", money.format(999)
  end

  def test_formats_a_whole_dollar_loss
    assert_equal "-$1", money.format(-100)
    assert_equal "-$6", money.format(-600)
  end

  def test_formats_a_fractional_loss
    assert_equal "-$0.05", money.format(-5)
    assert_equal "-$1.50", money.format(-150)
  end

  def test_renders_the_prescription_money_constants
    assert_equal "$5",  money.format(PrescriptionReport::Prescription::FILL_REVENUE_CENTS)
    assert_equal "-$6", money.format(PrescriptionReport::Prescription::RETURN_DELTA_CENTS)
  end
end
