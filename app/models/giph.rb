require 'json'
require 'net/http'

class Giph
  # the code in this class is responsible for 
  # - sending an HTTP request to the Giphy API
  # - looking at the data that gets sent back from that API and organizing it
  attr_accessor :image_url

  def initialize(url)
    self.image_url = url
  end

  def self.search_and_retreive_giphs(keyword)
    url = "http://api.giphy.com/v1/gifs/search?q=#{keyword}&api_key=dc6zaTOxFJmzC"
    response = self.get_api_response(url)
    self.make_giphs(response)
  end

  def self.get_api_response(endpoint)
    uri = URI.parse(URI.encode(endpoint))
    api_response = Net::HTTP.get(uri)
    JSON.parse(api_response)
  end

  def self.make_giphs(response)
    urls = response["data"].collect do |gif|
      image_url = gif["images"]["fixed_height"]["url"]
    end

    urls.collect do |url|
      Giph.new(url)
    end
  end
end
