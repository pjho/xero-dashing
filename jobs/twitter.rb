require 'twitter'

##
# Use Environment Variables to keep API keys private
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key =  ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret =  ENV['ACCESS_TOKEN_SECRET']
end

##
# Set default tweets in case of API failure
def default_tweets
  tweets = [
    { name: "@xero", body: sanitize("Coffee + Code = Beautiful Accounting #xero #coffee"), avatar: "https://pbs.twimg.com/profile_images/490207413933309952/_LiT6IcT_bigger.png" },
    { name: "@patnz", body: sanitize("RT @Xero - Coffee + Code = Beautiful Accounting #xero #coffee"), avatar: "https://pbs.twimg.com/profile_images/124955173/avatar_bigger.jpg" }
  ]
end

##
# Process Tweet body - break long words & wrap search terms in a span for styling.
def sanitize(body)
  # If a tweet contains a long string of non breaking letters it breaks the layout of the widget.
  # Using CSS doesn't seem to work so this is a quick & dirty hack to force words to wrap.
  body = body.split.map do |word| 
    word.size > 30 ? word.chars.each_slice(30).to_a.map { |arr| arr.push('-').join }.join[0..-2] : word
  end
  body.join(" ").gsub(/[@#]?(coffee|xero)/i) { |match| "<span class='twitter-#{match.downcase.gsub(/[#@]/,'')}'>#{match}</span>" }
end

search_term = URI::encode('xero AND coffee')

SCHEDULER.every '10m', :first_in => 0 do |job|

  begin
    tweets = twitter.search(search_term)
    if tweets
      tweets = tweets.map do |tweet|
        { name: tweet.user.name, body: sanitize(tweet.text), avatar: tweet.user.profile_image_url_https }
      end
    end
    send_event('twitter_mentions', comments: tweets)
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  ensure
    # Send defaults if Tweets API search has failed
    if tweets.nil? || tweets.size < 1
      tweets = default_tweets 
      send_event('twitter_mentions', comments: tweets)
    end
  end
end