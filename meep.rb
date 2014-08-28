require 'bundler'
Bundler.require
require 'angelo/mustermann'
require 'angelo/tilt/erb'


class Meep < Angelo::Base
  include Angelo::Tilt::ERB
  include Angelo::Mustermann

  NULL_ISLAND = Terraformer::Point.new(0,0).to_feature

  @@twitter = Twitter::REST::Client.new do |config|
    config.consumer_key = ''
    config.consumer_secret = ''
  end

  def self.twitter; @@twitter; end

  get '/:user/status/:id' do
    @tweet = @@twitter.status params[:id]
    if @tweet.geo?
      @point = Terraformer::Point.new(@tweet.geo.longitude, @tweet.geo.latitude).to_feature
    else
      @point = NULL_ISLAND
    end
    @longitude = @point.geometry.coordinates.x
    @latitude = @point.geometry.coordinates.y
    @point.properties[:popup] = erb :_popup, layout: false
    erb :map
  end

end

Meep.run
