xero_staff = 1138
coffees_per_day = 3069
per_coffee_weight = 0.015 # kgs i.e. 15 grams per coffee
kgs_per_day = coffees_per_day * per_coffee_weight
coffees_per_staff_member = coffees_per_day / xero_staff

# Percentage Multiplier Midnight - Midnight
time_multiplier_map = [
  1, 1, 1, 1, 1, # Midnight to 5am
  3, 3,
  7, 7,
  15,
  6, 6, 6,
  7.5, 7.5,
  4, 4, 4,
  3, 3, 3,
  2, 2, 2
]

# Percetage multiplier - Monday to Sunday
day_multiplier_map = [1.7, 1.2, 1.4, 1.2, 1.2, 0.2, 0.1 ]

# 

SCHEDULER.every '20s' do
# SCHEDULER.every '15m' do
  daily_percent_consumed = 0
  now = Time.now
  day = now.strftime("%u").to_i # 0-7 0 = Monday
  hour = now.strftime("%k").to_i # 0-23
  minute = now.strftime("%M").gsub(/^0/,'').to_i # 0-60

  time_multiplier_map[0..(hour - 1)].each do |hour|
    daily_percent_consumed += hour
  end
  
  daily_percent_consumed += time_multiplier_map[hour] * (minute / 60.0)

  send_event('dpc', { value: daily_percent_consumed.to_i })

end