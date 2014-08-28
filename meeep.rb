require 'bundler'
Bundler.require
require 'angelo/mustermann'
require 'angelo/tilt/erb'

class Meeep < Angelo::Base
  include Angelo::Tilt::ERB
  include Angelo::Mustermann

  DATE_FORMAT = '%b %-d'

  BASEMAPS = {
    'esri' => 'http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
    'null_island' => ''
  }

  NULL_ISLAND = Terraformer::Point.new(0,0).to_feature

  @@twitter = Twitter::REST::Client.new do |config|
    config.consumer_key = ''
    config.consumer_secret = ''
  end

  get '/:user/status/:id' do
    @basemap = BASEMAPS[params[:basemap]] || BASEMAPS['esri'] if params[:basemap]
    @tweet = @@twitter.status params[:id]
    if @tweet.geo?
      @point = Terraformer::Point.new(@tweet.geo.longitude, @tweet.geo.latitude).to_feature
      @basemap ||= BASEMAPS['esri']
    else
      @point = NULL_ISLAND
      @basemap ||= BASEMAPS['null_island']
    end
    @longitude = @point.geometry.coordinates.x
    @latitude = @point.geometry.coordinates.y
    @point.properties[:popup] = erb :_popup, layout: false
    erb :map
  end

end

Meeep.run
