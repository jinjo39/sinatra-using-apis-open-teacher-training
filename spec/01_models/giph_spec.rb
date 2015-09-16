require 'spec_helper'

describe 'Giph' do
  
  context 'instance methods' do
    it 'initializes with an argument of an image url' do 
      expect{Giph.new("http://media0.giphy.com/media/voF1Droc9eISs/200.gif")}.to_not raise_error
    end
    
    it 'has an attr_accessor for image_url' do
      giph = Giph.new("http://media0.giphy.com/media/voF1Droc9eISs/200.gif")
      expect(giph.image_url).to eq("http://media0.giphy.com/media/voF1Droc9eISs/200.gif") 
    end

  end
  
  context 'class methods' do
    describe '.get_api_response' do 
      it 'sends a request to the Giphy API and returns a collection of giphy data' do 
        VCR.use_cassette('moods/angry') do
          query = "http://api.giphy.com/v1/gifs/search?q=angry&api_key=dc6zaTOxFJmzC"
          # puts Giph.get_api_response(query)
          expect(Giph.get_api_response(query)).to be_a(Hash)
        end
      end
    end

    describe '.make_giphs' do 
      it 'operates on the hash returned by the .get_api_response method to instantiate a collection of Giph instances with the correct image_urls' do 
        VCR.use_cassette('moods/happy') do 
          query = "http://api.giphy.com/v1/gifs/search?q=happy&api_key=dc6zaTOxFJmzC"
          response = Giph.get_api_response(query)
          giphs = Giph.make_giphs(response)
          expect(giphs.length).to eq(25)
          expect(giphs.first).to be_a(Giph)
        end
      end
    end

    describe '.search_and_retreive_giphs' do 
      it 'takes in an argument of a keyword and calls on the .get_api_response and .make_giph methods to send a request to Giphy API and use the response to make Giph instances' do 
        VCR.use_cassette('moods/silly') do
          keyword = "silly"
          giphs = Giph.search_and_retreive_giphs(keyword)
          expect(giphs.length).to eq(25)
          expect(giphs.first).to be_a(Giph)
        end
      end
    end
  end 
end