xero_staff = 1138
kgs_per_week = 322;
per_coffee_weight = 0.015 # kgs i.e. 15 grams per coffee

total_coffees_per_week = kgs_per_week / per_coffee_weight
av_coffees_per_day = total_coffees_per_week / 7
av_kgs_per_day = kgs_per_week / 7
coffees_per_staff_member = av_coffees_per_day / xero_staff

##
# Percentage Multiplier Midnight - Midnight
# Highest consumption in the morning and steady in the early afternoon. 
# Low consumption in the wee hours for the freaks who go all night!
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

##
# Percetage multiplier - Monday to Sunday
# Highest consumption on Monday, lowest Sunday when most people aren't working
day_multiplier_map = [1.7, 1.2, 1.4, 1.2, 1.2, 0.2, 0.1 ]



SCHEDULER.every '1m' do
# SCHEDULER.every '15m' do
  daily_percent_consumed = 0
  now = Time.now
  day = now.strftime("%u").to_i # 0-7 0 = Monday
  hour = now.strftime("%k").to_i # 0-23
  minute = now.strftime("%M").gsub(/^0/,'').to_i # 0-60

  ##
  # Calculate % of daily coffees consumed
  # It's Safer to add them all each time rather than increment each iteration
  time_multiplier_map[0..(hour - 1)].each do |hour|
    daily_percent_consumed += hour
  end
  daily_percent_consumed += time_multiplier_map[hour] * (minute / 60.0)

  ##
  # Calculate Number of coffees consumed
  total_coffees_today = av_coffees_per_day * day_multiplier_map[day - 1]
  current_number_consumed = total_coffees_today * daily_percent_consumed / 100
  
  ## 
  # Calculate points for graph - Coffees per hour last 24 hours
  total_coffees_yesterday = av_coffees_per_day * day_multiplier_map[day - 2]
  yesterdays_values = time_multiplier_map[hour + 1..-1].each_with_index.map do |v, i| 
    { :x => i + hour + 1 , :y => (v / 100.0 * total_coffees_yesterday).round } 
  end

  todays_values = time_multiplier_map[0..hour].each_with_index.map do |v, i| 
    { :x => i , :y => (v / 100.0 * total_coffees_today).round, :name => i } 
  end

  # points = yesterdays_values.concat(todays_values)
  points = todays_values

##
# Set some interesting numbers based off the values we have to display in list
stats = [
  {:label=>"# of Xero Staff", :value=>xero_staff},
  {:label=>"Avg. Coffees Per Person Per Day", :value=>coffees_per_staff_member.round(2)},
  {:label=>"Grams of Coffee per cup", :value=>per_coffee_weight.round(2)},
  {:label=>"Kgs Coffee Per Week", :value=>kgs_per_week.round(2)},
  {:label=>"Number of Coffees Per Week", :value=>total_coffees_per_week.round},
  {:label=>"Avg Number of Coffees Per Day", :value=>av_coffees_per_day.round},
  {:label=>"# Coffees on a Sunday", :value=>(av_coffees_per_day * day_multiplier_map[6]).round},
  {:label=>"# Coffees on a Monday", :value=>(av_coffees_per_day * day_multiplier_map[0]).round},
]

  send_event('caffeine_dpc', { value: daily_percent_consumed.to_i, moreinfo: "of an estimated #{total_coffees_today.to_i} coffees" })
  send_event('caffeine_totals',{ total_today: total_coffees_today.to_i, current_consumed: current_number_consumed.to_i })
  send_event('caffeine_hour_map',{ points: points})
  send_event('caffeine_in_numbers',{ items: stats })
end