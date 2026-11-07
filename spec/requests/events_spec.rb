# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Events API" do
  describe "GET /api/events" do
    it "lists only active events, dated ones first in start order, undated last" do
      undated = create_event(slug: "undated", starts_at: nil)
      later = create_event(slug: "later", starts_at: 2.days.from_now)
      sooner = create_event(slug: "sooner", starts_at: 1.day.from_now)
      create_event(slug: "hidden", active: false, starts_at: 1.hour.from_now)

      get "/api/events"

      expect(response).to have_http_status(:ok)
      slugs = response.parsed_body["events"].map { |e| e["slug"] }
      expect(slugs).to eq([sooner.slug, later.slug, undated.slug])
    end

    it "returns an empty list when there are no events" do
      get "/api/events"
      expect(response.parsed_body).to eq("events" => [])
    end
  end

  describe "GET /api/events/:slug" do
    it "returns the public view of the event with live seat counts" do
      event = create_event(slug: "show-me", capacity: 4, free_dev_seats: 1)
      create_registration(event, seat_type: "dev")

      get "/api/events/show-me"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("slug" => "show-me", "seats_remaining" => 3,
                                              "dev_seats_remaining" => 0, "full" => false)
    end

    it "404s an unknown slug" do
      get "/api/events/nope"
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "event not found")
    end
  end
end
