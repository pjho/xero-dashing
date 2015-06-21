# Populate the graph with some random points
points = []
(1..10).each do |i|
  points << { x: i, y: rand(50) }
end
last_x = points.last[:x]

SCHEDULER.every '55s' do
  points.shift
  last_x += 1
  points << { x: last_x, y: rand(50) }
  # puts points.to_s
  send_event('convergence', points: points)
end