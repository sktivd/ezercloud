class GoogleMapsController < ApplicationController
  before_action only: [:index] do
    authorize Diagnosis, :map?
  end
  
  def index
    if current_account.is_admin?
      # administrators only access whole diagnosis data.
      @diagnosis = Diagnosis.all

      # full time scale    
      @available_timescale = [0, 1, 2, 3, 4, 5, 6, 7]
      @current_timescale   = 1
      @time_labels         = ['D', 'W', 'M', 'Q', 'H', 'Y', '2', 'w']
    else
      @diagnosis = Diagnosis.where(measured_at: 2.years.ago..DateTime.now)

      # full time scale    
      @available_timescale = [0, 1, 2, 3, 4, 5, 6]
      @current_timescale   = 1
      @time_labels         = ['D', 'W', 'M', 'Q', 'H', 'Y', '2']
    end
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
  end
    
end
