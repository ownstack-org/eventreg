module Api
  class RegistrationsController < ApplicationController
    # POST /api/events/:event_slug/registrations
    def create
      event = Event.find_by(slug: params[:event_slug])
      return render json: { error: "event not found" }, status: :not_found unless event

      email = params[:email].to_s.strip.downcase
      if email.present?
        existing = event.registrations.find_by(email: email)
        if existing
          return render json: {
            status: "already_registered",
            registration: existing.as_public_json,
            seats_remaining: event.seats_remaining,
            dev_seats_remaining: event.dev_seats_remaining
          }, status: :ok
        end
      end

      seat_type = params[:seat_type].to_s.downcase
      seat_type = (event.free? ? "free" : "paid") unless Registration::SEAT_TYPES.include?(seat_type)

      if event.full?
        return render json: { error: "event is full", seats_remaining: 0 }, status: :unprocessable_entity
      end
      if seat_type == "dev" && event.dev_seats_remaining <= 0
        return render json: {
          error: "no free developer seats remaining",
          seats_remaining: event.seats_remaining,
          dev_seats_remaining: 0
        }, status: :unprocessable_entity
      end

      source = params[:source].to_s.downcase
      source = "web" unless Registration::SOURCES.include?(source)

      reg = event.registrations.new(
        name: params[:name],
        email: email,
        phone: params[:phone],
        seat_type: seat_type,
        source: source,
        registered_by: params[:registered_by].presence
      )

      if reg.save
        render json: {
          status: "registered",
          registration: reg.as_public_json,
          message: confirmation_message(reg, event),
          seats_remaining: event.seats_remaining,
          dev_seats_remaining: event.dev_seats_remaining
        }, status: :created
      else
        render json: { error: "invalid registration", details: reg.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # GET /api/events/:event_slug/registrations  (admin, X-Admin-Token)
    def index
      event = Event.find_by(slug: params[:event_slug])
      return render json: { error: "event not found" }, status: :not_found unless event
      return render json: { error: "unauthorized" }, status: :unauthorized unless authorized?

      render json: {
        event: event.slug,
        count: event.total_count,
        seats_remaining: event.seats_remaining,
        dev_seats_remaining: event.dev_seats_remaining,
        registrations: event.registrations.order(:created_at).map(&:as_public_json)
      }
    end

    private

    def authorized?
      token = request.headers["X-Admin-Token"].to_s
      admin = ENV["ADMIN_TOKEN"].to_s
      admin.present? && ActiveSupport::SecurityUtils.secure_compare(token, admin)
    end

    def confirmation_message(reg, event)
      seat = reg.seat_type == "dev" ? "a free developer seat" : "a seat"
      "#{reg.name} is registered for #{event.name} (#{seat}). #{event.seats_remaining} seats remaining."
    end
  end
end
