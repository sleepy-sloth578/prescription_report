# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::Prescription do
  let(:prescription) { PrescriptionReport::Prescription.new }

  def test_starts_empty
    assert_equal 0, prescription.outstanding_fills
    assert_equal 0, prescription.income_cents
    refute_predicate prescription, :returnable?
  end

  def test_a_fill_adds_one_outstanding_and_five_dollars
    prescription.fill

    assert_equal 1,   prescription.outstanding_fills
    assert_equal 500, prescription.income_cents
  end

  def test_fills_accumulate
    3.times { prescription.fill }

    assert_equal 3,    prescription.outstanding_fills
    assert_equal 1500, prescription.income_cents
  end

  def test_a_return_cancels_a_fill_in_both_count_and_money
    prescription.fill
    prescription.return_fill

    assert_equal 0,    prescription.outstanding_fills
    assert_equal(-100, prescription.income_cents)
  end

  def test_the_return_loss_survives_a_later_refill
    prescription.fill
    prescription.return_fill
    prescription.fill

    assert_equal 1,   prescription.outstanding_fills
    assert_equal 400, prescription.income_cents
  end

  def test_not_returnable_when_no_fills
    refute_predicate prescription, :returnable?
  end

  def test_returnable_after_a_fill
    prescription.fill

    assert_predicate prescription, :returnable?
  end

  def test_not_returnable_once_every_fill_is_returned
    prescription.fill
    prescription.return_fill

    refute_predicate prescription, :returnable?
  end

  def test_counts_and_income_are_consistent
    10.times { prescription.fill }
    4.times  { prescription.return_fill }

    assert_equal 6,    prescription.outstanding_fills
    assert_equal 2600, prescription.income_cents
  end
end
