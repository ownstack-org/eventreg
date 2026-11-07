# frozen_string_literal: true

require "rails_helper"

RSpec.describe "application base classes" do
  it "routes jobs and mail through the app's base classes" do
    expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
    expect(ApplicationMailer.default[:from]).to eq("from@example.com")
    expect(ApplicationRecord).to be_abstract_class
  end
end
