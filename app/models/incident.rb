class Incident < ApplicationRecord
  SEVERITIES = %w[sev1 sev2 sev3].freeze

  before_validation :sanitize_severity

  private

  def sanitize_severity
    self.severity = nil unless SEVERITIES.include?(severity)
  end
end
