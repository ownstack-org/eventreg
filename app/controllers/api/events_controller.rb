module Api
  class EventsController < ApplicationController
    def index
      events = Event.where(active: true).order(Arel.sql("starts_at IS NULL, starts_at ASC"))
      render json: { events: events.map(&:as_public_json) }
    end

    def show
      event = Event.find_by(slug: params[:slug])
      return render json: { error: "event not found" }, status: :not_found unless event

      render json: event.as_public_json
    end
  end
end
