# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::Ledger do
  def ledger_for(input)
    PrescriptionReport::Ledger.new.ingest(input)
  end

  def net_cents(input)
    ledger_for(input).net_cents
  end

  def test_a_fill_earns_five_dollars
    assert_equal 500, net_cents("Mark B created\nMark B filled\n")
  end

  def test_a_fill_then_return_nets_one_dollar_loss
    assert_equal(-100, net_cents("Mark B created\nMark B filled\nMark B returned\n"))
  end

  def test_created_alone_earns_nothing
    assert_equal 0, net_cents("Mark B created\n")
  end

  def test_income_is_exact_over_many_cycles
    lines = ["P B created"] + (["P B filled", "P B returned"] * 500)

    assert_equal(-500 * 100, net_cents(lines.join("\n")))
  end

  # --- lifecycle rules ---

  def test_fill_before_create_is_discarded
    ledger = ledger_for("Mark B filled\n")

    assert_equal 0, ledger.net_cents
    assert_equal 1, ledger.rejections.size
    assert_match(/never created/, ledger.rejections.first.detail)
  end

  def test_return_before_create_is_discarded
    ledger = ledger_for("Mark B returned\n")

    assert_equal 0, ledger.net_cents
    assert_equal 1, ledger.rejections.size
  end

  def test_return_without_an_outstanding_fill_is_discarded
    ledger = ledger_for("Mark B created\nMark B returned\n")

    assert_equal 0, ledger.net_cents
    assert_match(/no outstanding fill/, ledger.rejections.first.detail)
  end

  def test_a_prescription_can_be_filled_repeatedly
    ledger = ledger_for("Mark B created\nMark B filled\nMark B filled\nMark B filled\n")

    assert_equal 1500, ledger.net_cents
    assert_equal 3, ledger.summaries.first.fills
  end

  def test_a_returned_prescription_can_be_filled_again
    ledger = ledger_for("Mark B created\nMark B filled\nMark B returned\nMark B filled\n")

    assert_equal 400, ledger.net_cents
    assert_equal 1, ledger.summaries.first.fills
  end

  def test_duplicate_create_is_discarded_and_does_not_reset_state
    ledger = ledger_for("Mark B created\nMark B filled\nMark B created\n")

    assert_equal 500, ledger.net_cents
    assert_equal 1, ledger.prescription_count
    assert_match(/already exists/, ledger.rejections.first.detail)
  end

  def test_more_returns_than_fills_cannot_drive_the_count_negative
    ledger = ledger_for("Mark B created\nMark B filled\nMark B returned\nMark B returned\n")

    assert_equal(-100, ledger.net_cents)
    assert_equal 0, ledger.summaries.first.fills
    assert_equal 1, ledger.rejections.size
  end

  def test_one_patient_many_drugs_are_tracked_independently
    ledger = ledger_for(<<~EVENTS)
      Mark B created
      Mark C created
      Mark B filled
      Mark C filled
      Mark B returned
    EVENTS

    assert_equal 400, ledger.net_cents
    assert_equal 2, ledger.prescription_count
    assert_equal 1, ledger.summaries.size
    assert_equal 1, ledger.summaries.first.fills
  end

  def test_a_patient_with_only_discarded_events_is_absent
    ledger = ledger_for("Nick A created\nPaul D filled\n")

    patients = ledger.summaries.map(&:patient)

    assert_includes patients, "Nick"
    refute_includes patients, "Paul"
  end

  def test_summaries_are_ordered_by_fills_desc_then_name
    ledger = ledger_for(<<~EVENTS)
      Bob B created
      Ann A created
      Zed Z created
      Bob B filled
      Ann A filled
      Zed Z filled
      Zed Z filled
    EVENTS

    assert_equal %w[Zed Ann Bob], ledger.summaries.map(&:patient)
  end

  def test_the_provided_sample_reproduces_the_expected_report
    ledger = ledger_for(<<~EVENTS)
      Nick A created
      Mark B created
      Mark B filled
      Mark C filled
      Mark B returned
      John E created
      Mark B filled
      Mark B filled
      Paul D filled
      John E filled
      John E returned
    EVENTS

    assert_equal [
      "Mark: 2 fills $9 income",
      "John: 0 fills -$1 income",
      "Nick: 0 fills $0 income"
    ], ledger.summaries.map(&:to_s)
  end

  def test_prescription_count_reflects_only_created_prescriptions
    ledger = ledger_for("Mark B created\nMark C created\nMark D filled\n")

    assert_equal 2, ledger.prescription_count
  end

  def test_rejections_carry_the_source_line
    ledger = ledger_for("Mark B created\n\nMark B returned\n")

    assert_equal 3, ledger.rejections.first.source_line
  end
end
