# frozen_string_literal: true

module PrescriptionReport
  # Applies events one at a time and accumulates per-patient results.
  class Ledger
    attr_reader :rejections

    def initialize
      @prescriptions = {}
      @patients      = {}
      @rejections    = []
    end

    def ingest(io)
      Reader.new(io).each do |result|
        result.is_a?(Rejection) ? @rejections << result : apply(result)
      end
      self
    end

    def summaries
      @patients.map { |patient, list| summarize(patient, list) }
               .sort_by { |summary| [-summary.fills, summary.patient] }
    end

    private

    def apply(event)
      case event.type
      when EventType::CREATED  then handle_created(event)
      when EventType::FILLED   then handle_filled(event)
      when EventType::RETURNED then handle_returned(event)
      end
    end

    def summarize(patient, list)
      PatientSummary.new(
        patient: patient,
        fills: list.sum(&:outstanding_fills),
        income_cents: list.sum(&:income_cents)
      )
    end

    def handle_created(event)
      return reject(event, "prescription already exists") if @prescriptions.key?(event.key)

      prescription = Prescription.new
      @prescriptions[event.key] = prescription
      (@patients[event.patient] ||= []) << prescription
    end

    def handle_filled(event)
      prescription = @prescriptions[event.key]
      return reject(event, "prescription was never created") if prescription.nil?

      prescription.fill
    end

    def handle_returned(event)
      prescription = @prescriptions[event.key]
      return reject(event, "prescription was never created") if prescription.nil?
      return reject(event, "no outstanding fill to return") unless prescription.returnable?

      prescription.return_fill
    end

    def reject(event, detail)
      @rejections << Rejection.new(
        source_line: event.source_line,
        reason: "invalid #{event.type}",
        detail: "#{event} -- #{detail}"
      )
    end
  end
end
