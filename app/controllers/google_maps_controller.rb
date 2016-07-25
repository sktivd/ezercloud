class GoogleMapsController < ApplicationController
  before_action only: [:index] do
    allow_only_to :monitoring
  end
  
  def index
    @diagnosis = Diagnosis.read
    @gmap_assays = Set.new
    @gmap_equipment = Set.new
    
    @diagnosis_markers = Gmaps4rails.build_markers(@diagnosis) do |diagnosis, marker|
      # marker info
      marker.lat diagnosis.latitude
      marker.lng diagnosis.longitude
      marker.infowindow "MMM"
      marker.title diagnosis.decision
      marker.json assay: diagnosis.diagnosis_tag, equipment: diagnosis.equipment, id: diagnosis.id, days: ((Time.now - diagnosis.measured_at) / 86400).to_i
      
      # auxiliary info
      @gmap_assays.add diagnosis.diagnosis_tag
      @gmap_equipment.add diagnosis.equipment
    end
    
    @diagnosis_labels = {
      'Positive' => '#FF0066',
      'Negative' => '#6600FF',
      'Invalid' => '#00FF66',
      'Suspended' => '#7F7F7F'
    }
    
    # full time scale
    @available_timescale = [0, 1, 2, 3, 4, 5, 6, 7]
    @current_timescale   = 1
    @time_labels         = ['D', 'W', 'M', 'Q', 'H', 'Y', '2', 'w']
  end
    
end
