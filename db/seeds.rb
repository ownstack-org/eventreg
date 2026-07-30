# Idempotent seed. The Sonoma AI x SOMO Village event.
sonoma = Event.find_or_initialize_by(slug: "sonoma-ai-2026-10-09")
sonoma.assign_attributes(
  name: "Sonoma AI at SOMO Village",
  starts_at: Time.utc(2026, 10, 9, 23, 0),   # 4 PM PT
  ends_at: Time.utc(2026, 10, 10, 2, 0),     # 7 PM PT
  location: "SOMO Cowork, SOMO Village, Rohnert Park, CA",
  description: "An evening of agentic AI and automating your work. Short talks, then breakout rooms (beginners, startup pitch, office hours), closing with a happy hour at Old Caz.",
  capacity: 100,
  free_dev_seats: 15,
  price_cents: 1500,
  currency: "USD",
  active: true
)
sonoma.save!
puts "Seeded event: #{sonoma.slug} (#{sonoma.seats_remaining} seats, #{sonoma.dev_seats_remaining} free dev seats)"
