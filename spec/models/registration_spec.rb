# frozen_string_literal: true

require "rails_helper"

RSpec.describe Registration do
  let(:event) { create_event }

  it "normalizes email, name and phone before validating" do
    reg = event.registrations.create!(name: "  Grace  ", email: "  Grace@Example.COM ", phone: " 555-0100 ",
                                      seat_type: "free")
    expect(reg.reload).to have_attributes(name: "Grace", email: "grace@example.com", phone: "555-0100")
  end

  it "stores a blank phone as nil" do
    reg = create_registration(event, phone: "   ")
    expect(reg.phone).to be_nil
  end

  it "requires a name and a well formed email" do
    reg = event.registrations.new(name: " ", email: "not-an-email", seat_type: "free")
    expect(reg).not_to be_valid
    expect(reg.errors[:name]).to include("can't be blank")
    expect(reg.errors[:email]).to include("is invalid")
  end

  it "requires an email" do
    reg = event.registrations.new(name: "X", email: "", seat_type: "free")
    expect(reg).not_to be_valid
    expect(reg.errors[:email]).to include("can't be blank")
  end

  it "allows one registration per email per event, ignoring case" do
    create_registration(event, email: "dup@example.com")
    dup = event.registrations.new(name: "Again", email: "DUP@example.com", seat_type: "free")
    expect(dup).not_to be_valid
    expect(dup.errors[:email]).to include("has already been taken")

    other = create_event
    expect(other.registrations.new(name: "Again", email: "dup@example.com", seat_type: "free")).to be_valid
  end

  it "rejects an unknown seat type" do
    reg = event.registrations.new(name: "X", email: "x@example.com", seat_type: "vip")
    expect(reg).not_to be_valid
    expect(reg.errors[:seat_type]).to include("is not included in the list")
  end

  it "builds the admin view with personal details" do
    reg = create_registration(event, name: "Ada", email: "ada@example.com", phone: "555", seat_type: "dev",
                                     source: "agent", registered_by: "claude")
    expect(reg.as_public_json).to include(id: reg.id, event: event.slug, name: "Ada", email: "ada@example.com",
                                          phone: "555", seat_type: "dev", source: "agent", registered_by: "claude")
  end

  it "builds the public confirmation without personal details" do
    reg = create_registration(event, name: "Ada", phone: "555", registered_by: "claude")
    json = reg.as_confirmation_json
    expect(json).to eq(event: event.slug, seat_type: "free", created_at: reg.created_at)
  end
end
