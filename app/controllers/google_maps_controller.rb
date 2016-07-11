class GoogleMapsController < ApplicationController
  before_action only: [:index] do
    allow_only_to :monitoring
  end
  
  def index
    @diagnosis = Diagnosis.read
    
    @diagnosis_markers = Gmaps4rails.build_markers(@diagnosis) do |diagnosis, marker|
      marker.lat diagnosis.latitude
      marker.lng diagnosis.longitude
      marker.infowindow "MMM"
      marker.title diagnosis.decision
#      marker.id 
    end
    
    @diagnosis_labels = {
      'Positive' => '#FF0066',
      'Negative' => '#6600FF',
      'Invalid' => '#00FF66',
      'Suspended' => '#7F7F7F'
    }
  end
    
end
