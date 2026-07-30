class Registration < ApplicationRecord
  SEAT_TYPES = %w[paid free dev].freeze
  SOURCES = %w[web api agent github].freeze

  belongs_to :event

  before_validation do
    self.email = email.to_s.strip.downcase.presence
    self.name = name.to_s.strip.presence
    self.phone = phone.to_s.strip.presence
  end

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :event_id, case_sensitive: false }
  validates :seat_type, inclusion: { in: SEAT_TYPES }

  def as_public_json
    {
      id: id,
      event: event.slug,
      name: name,
      email: email,
      phone: phone,
      seat_type: seat_type,
      source: source,
      registered_by: registered_by,
      created_at: created_at
    }
  end
end
