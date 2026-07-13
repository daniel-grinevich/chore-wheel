# Idempotent seeds: the two people and a starter set of chores so week one has
# data before any timers have run. Rename people/chores freely in the UI.

people = [
  { name: "Daniel",  color: "#4f46e5" }, # indigo
  { name: "Partner", color: "#db2777" }  # pink
]
people.each do |attrs|
  Person.find_or_create_by!(name: attrs[:name]) { |p| p.color = attrs[:color] }
end

starter_chores = [
  { name: "Wash dishes",      base_estimate_minutes: 15 },
  { name: "Take out trash",   base_estimate_minutes: 5 },
  { name: "Vacuum floors",    base_estimate_minutes: 20 },
  { name: "Clean bathroom",   base_estimate_minutes: 30 },
  { name: "Laundry",          base_estimate_minutes: 40 },
  { name: "Wipe counters",    base_estimate_minutes: 10 },
  { name: "Grocery shopping", base_estimate_minutes: 45 },
  { name: "Make the bed",     base_estimate_minutes: 5 }
]
starter_chores.each do |attrs|
  Chore.find_or_create_by!(name: attrs[:name]) do |c|
    c.base_estimate_minutes = attrs[:base_estimate_minutes]
    c.active = true
  end
end

puts "Seeded #{Person.count} people and #{Chore.count} chores."
