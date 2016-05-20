class GoogleMapsController < ApplicationController
  before_action only: [:index] do
    allow_only_to :monitoring
  end
  
  def index
    @diagnosis = Diagnosis.read
    
    @hash = Gmaps4rails.build_markers(@diagnosis) do |diagnosis, marker|
      marker.lat diagnosis.latitude
      marker.lng diagnosis.longitude
    end    
  end
    
end
