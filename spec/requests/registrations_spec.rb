# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations API" do
  let(:event) { create_event(slug: "night", name: "Night", capacity: 3, free_dev_seats: 1, price_cents: 0) }
  let(:valid) { { name: "Ada Lovelace", email: "Ada@Example.com", phone: "555-0100" } }

  def register(slug = event.slug, params = valid)
    post "/api/events/#{slug}/registrations", params: params, as: :json
  end

  describe "POST /api/events/:slug/registrations" do
    it "registers a person, normalizes the email and answers with the seat counts and a message" do
      expect { register }.to change(event.registrations, :count).by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body).to include("status" => "registered", "seats_remaining" => 2, "dev_seats_remaining" => 1)
      expect(body["registration"]).to include("email" => "ada@example.com", "seat_type" => "free",
                                              "source" => "web", "registered_by" => nil)
      expect(body["message"]).to eq("Ada Lovelace is registered for Night (a seat). 2 seats remaining.")
    end

    it "defaults the seat to paid on a priced event" do
      event.update!(price_cents: 1500)
      register
      expect(event.registrations.last.seat_type).to eq("paid")
    end

    it "ignores an unknown seat type and an unknown source" do
      register(event.slug, valid.merge(seat_type: "VIP", source: "carrier-pigeon"))
      expect(event.registrations.last).to have_attributes(seat_type: "free", source: "web")
    end

    it "claims a free developer seat for an agent and records who registered them" do
      register(event.slug, valid.merge(seat_type: "DEV", source: "Agent", registered_by: "claude-code"))

      expect(response).to have_http_status(:created)
      reg = event.registrations.last
      expect(reg).to have_attributes(seat_type: "dev", source: "agent", registered_by: "claude-code")
      expect(response.parsed_body["message"]).to include("(a free developer seat)")
      expect(response.parsed_body["dev_seats_remaining"]).to eq(0)
    end

    it "refuses a developer seat once the pool is gone, and registers nothing" do
      create_registration(event, seat_type: "dev")

      expect { register(event.slug, valid.merge(seat_type: "dev")) }.not_to change(Registration, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("error" => "no free developer seats remaining", "seats_remaining" => 2,
                                         "dev_seats_remaining" => 0)
    end

    it "refuses any seat once the event is full" do
      3.times { create_registration(event) }

      expect { register }.not_to change(Registration, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq("error" => "event is full", "seats_remaining" => 0)
    end

    it "is idempotent on email, and does not hand back the existing person's details" do
      create_registration(event, name: "Ada Lovelace", email: "ada@example.com", phone: "555-0100",
                                 registered_by: "someone")

      # A stranger who only knows the email must not learn the name, phone or registrar.
      expect { register(event.slug, { name: "Stranger", email: " ADA@example.com " }) }
        .not_to change(Registration, :count)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["status"]).to eq("already_registered")
      expect(body["registration"]).to eq("event" => "night", "seat_type" => "free",
                                         "created_at" => body["registration"]["created_at"])
      expect(response.body).not_to include("555-0100", "Ada Lovelace", "someone")
      expect(body).to include("seats_remaining" => 2, "dev_seats_remaining" => 1)
    end

    it "answers already registered even when the event has since filled" do
      create_registration(event, email: "ada@example.com")
      2.times { create_registration(event) }

      register
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("already_registered")
    end

    it "rejects an invalid registration with the reasons" do
      expect { register(event.slug, { name: "", email: "" }) }.not_to change(Registration, :count)
      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      expect(body["error"]).to eq("invalid registration")
      expect(body["details"]).to include("Name can't be blank", "Email can't be blank")
    end

    it "404s an unknown event" do
      register("nope")
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq("error" => "event not found")
    end
  end

  describe "GET /api/events/:slug/registrations (admin)" do
    around do |example|
      old = ENV["ADMIN_TOKEN"]
      ENV["ADMIN_TOKEN"] = "s3cret"
      example.run
    ensure
      ENV["ADMIN_TOKEN"] = old
    end

    it "lists every registration in signup order for the admin token" do
      first = create_registration(event, seat_type: "dev", created_at: 2.minutes.ago)
      second = create_registration(event, created_at: 1.minute.ago)

      get "/api/events/#{event.slug}/registrations", headers: { "X-Admin-Token" => "s3cret" }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to include("event" => "night", "count" => 2, "seats_remaining" => 1, "dev_seats_remaining" => 0)
      expect(body["registrations"].map { |r| r["id"] }).to eq([first.id, second.id])
      expect(body["registrations"].first).to include("email" => first.email, "name" => first.name)
    end

    it "is unauthorized with a wrong token or none" do
      create_registration(event)
      get "/api/events/#{event.slug}/registrations", headers: { "X-Admin-Token" => "wrong" }
      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq("error" => "unauthorized")

      get "/api/events/#{event.slug}/registrations"
      expect(response).to have_http_status(:unauthorized)
    end

    it "is unauthorized for everyone when no admin token is configured" do
      ENV["ADMIN_TOKEN"] = ""
      get "/api/events/#{event.slug}/registrations", headers: { "X-Admin-Token" => "" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "404s an unknown event" do
      get "/api/events/nope/registrations", headers: { "X-Admin-Token" => "s3cret" }
      expect(response).to have_http_status(:not_found)
    end
  end
end
