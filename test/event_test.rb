# frozen_string_literal: true

require_relative "test_helper"

describe PrescriptionReport::Event do
  let(:event) { PrescriptionReport::Event }
  let(:event_type) { PrescriptionReport::EventType }

  def build(**overrides)
    defaults = {
      patient: "Mark", drug: "B",
      type: event_type::FILLED, source_line: 3
    }
    event.new(**defaults, **overrides)
  end

  def test_exposes_each_field_it_was_built_with
    built = build(patient: "Dana", drug: "Amoxicillin",
                  type: event_type::CREATED, source_line: 7)

    assert_equal "Dana",        built.patient
    assert_equal "Amoxicillin", built.drug
    assert_equal event_type::CREATED, built.type
    assert_equal 7, built.source_line
  end

  def test_requires_every_field
    assert_raises(ArgumentError) do
      event.new(patient: "Mark", drug: "B", type: event_type::FILLED)
    end
  end

  def test_key_is_patient_and_drug_in_order
    assert_equal %w[Mark B], build(patient: "Mark", drug: "B").key
  end

  def test_to_s_is_human_readable
    built = build(patient: "Mark", drug: "B", type: event_type::RETURNED)

    assert_equal "Mark/B returned", built.to_s
  end
end
