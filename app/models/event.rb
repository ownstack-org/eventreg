class Event < ApplicationRecord
  has_many :registrations, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def total_count = registrations.count
  def dev_count = registrations.where(seat_type: "dev").count
  def seats_remaining = [capacity - total_count, 0].max
  def dev_seats_remaining = [free_dev_seats - dev_count, 0].max
  def full? = seats_remaining <= 0
  def free? = price_cents.to_i <= 0

  def as_public_json
    {
      slug: slug,
      name: name,
      starts_at: starts_at,
      ends_at: ends_at,
      location: location,
      description: description,
      capacity: capacity,
      seats_remaining: seats_remaining,
      free_dev_seats: free_dev_seats,
      dev_seats_remaining: dev_seats_remaining,
      price_cents: price_cents,
      currency: currency,
      full: full?
    }
  end
end
