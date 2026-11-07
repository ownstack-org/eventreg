# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event do
  describe "validations" do
    it "requires a name and a slug" do
      event = Event.new
      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("can't be blank")
      expect(event.errors[:slug]).to include("can't be blank")
    end

    it "rejects a duplicate slug" do
      create_event(slug: "taken")
      dup = Event.new(name: "Other", slug: "taken")
      expect(dup).not_to be_valid
      expect(dup.errors[:slug]).to include("has already been taken")
    end
  end

  describe "seat accounting" do
    let(:event) { create_event(capacity: 3, free_dev_seats: 1) }

    it "counts every registration against capacity and dev seats against the dev pool" do
      create_registration(event, seat_type: "dev")
      create_registration(event, seat_type: "free")

      expect(event.total_count).to eq(2)
      expect(event.dev_count).to eq(1)
      expect(event.seats_remaining).to eq(1)
      expect(event.dev_seats_remaining).to eq(0)
      expect(event).not_to be_full
    end

    it "is full at capacity and never reports negative seats" do
      event.update!(capacity: 1)
      create_registration(event)
      create_registration(event)

      expect(event.seats_remaining).to eq(0)
      expect(event).to be_full
    end

    it "never reports negative dev seats when the pool shrinks below what was claimed" do
      create_registration(event, seat_type: "dev")
      event.update!(free_dev_seats: 0)
      expect(event.dev_seats_remaining).to eq(0)
    end
  end

  describe "#free?" do
    it "is free at zero price and not free with a price" do
      expect(Event.new(price_cents: 0)).to be_free
      expect(Event.new(price_cents: 1500)).not_to be_free
    end
  end

  describe "#as_public_json" do
    it "exposes the listing fields and live seat counts" do
      event = create_event(slug: "pub", name: "Pub", location: "Here", capacity: 5, free_dev_seats: 2,
                           price_cents: 1500, currency: "USD")
      create_registration(event, seat_type: "dev")

      json = event.as_public_json
      expect(json).to include(slug: "pub", name: "Pub", location: "Here", capacity: 5, seats_remaining: 4,
                              free_dev_seats: 2, dev_seats_remaining: 1, price_cents: 1500, currency: "USD",
                              full: false)
      expect(json.keys).to include(:starts_at, :ends_at, :description)
    end
  end

  it "destroys its registrations with it" do
    event = create_event
    create_registration(event)
    expect { event.destroy }.to change(Registration, :count).by(-1)
  end
end
