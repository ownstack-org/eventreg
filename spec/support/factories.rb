# frozen_string_literal: true

# Small builders instead of a factory gem: the app has two models.
module Factories
  def create_event(**attrs)
    Event.create!({ name: "Test Night", slug: "test-night-#{SecureRandom.hex(3)}", capacity: 10,
                    free_dev_seats: 2, price_cents: 0 }.merge(attrs))
  end

  def create_registration(event, **attrs)
    event.registrations.create!({ name: "Ada Lovelace", email: "ada-#{SecureRandom.hex(3)}@example.com",
                                  seat_type: "free" }.merge(attrs))
  end
end

RSpec.configure { |c| c.include Factories }
