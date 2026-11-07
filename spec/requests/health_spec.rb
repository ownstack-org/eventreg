# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health and root" do
  it "answers /healthz with ok" do
    get "/healthz"
    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("ok")
  end

  it "answers the Rails health check at /up" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end

  # public/index.html wins over the root redirect: the static file server
  # answers / before the router does.
  it "serves the static home page at /" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("<title>Events")
  end
end
