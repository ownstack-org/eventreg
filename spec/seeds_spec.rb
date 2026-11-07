# frozen_string_literal: true

require "rails_helper"

RSpec.describe "db/seeds.rb" do
  it "creates the Sonoma AI event once, however many times it runs" do
    expect { 2.times { Rails.application.load_seed } }.to output(/Seeded event: sonoma-ai-2026-10-09/).to_stdout
    expect(Event.where(slug: "sonoma-ai-2026-10-09").count).to eq(1)
    expect(Event.find_by(slug: "sonoma-ai-2026-10-09")).to have_attributes(capacity: 100, free_dev_seats: 15)
  end
end
