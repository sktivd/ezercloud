class DiagnosisImagesController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :html_request?
  skip_before_action :authorize, only: [:create]
  before_action only: [:new, :update, :edit, :destroy] do
    allow_only_to :super
  end

  before_action :set_diagnosis_image, only: [:show, :edit, :update, :destroy]

  # GET /diagnosis_images
  # GET /diagnosis_images.json
  def index
    @diagnosis_images = DiagnosisImage.all
  end

  # GET /diagnosis_images/1
  # GET /diagnosis_images/1.json
  def show
  end

  # GET /diagnosis_images/new
  def new
    @image = DiagnosisImage.new
  end

  # GET /diagnosis_images/1/edit
  def edit
  end

  # POST /diagnosis_images
  # POST /diagnosis_images.json
  def create
    @equipment = set_equipment(params[:equipment], params[:anchor])
    if @equipment
      @diagnosis_image = @equipment.diagnosis_images.build(diagnosis_image_params)
      if @diagnosis_image.save
        render :created, status: :created, location: @diagnosis_image, formats: [:json]
      else
        @diagnosis_image.errors.add(:response, "fail")
        render json: @diagnosis_image.errors, status: :unprocessable_entity
      end
#      respond_to do |format|
#        if @image.save
#          format.html { redirect_to @diagnosis_image, notice: 'Diagnosis image was successfully created.' }
#          format.json { render :show, status: :created, location: @diagnosis_image }
#        else
#          format.html { render :new }
#          format.json { render json: @diagnosis_image.errors, status: :unprocessable_entity }
#        end
#      end
    else
      render json: { equipment: "#{params[:equipment]} \##{params[:anchor]} not exist" }
    end
  end

  # PATCH/PUT /diagnosis_images/1
  # PATCH/PUT /diagnosis_images/1.json
  def update
    respond_to do |format|
      if @diagnosis_image.update(diagnosis_image_params)
        format.html { redirect_to @diagnosis_image, notice: 'Diagnosis mage was successfully updated.' }
        format.json { render :show, status: :ok, location: @diagnosis_image }
      else
        format.html { render :edit }
        format.json { render json: @diagnosis_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diagnosis_images/1
  # DELETE /diagnosis_images/1.json
  def destroy
    @diagnosis_image.destroy
    respond_to do |format|
      format.html { redirect_to diagnosis_images_url, notice: 'Diagnosis image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diagnosis_image
      @diagnosis_image = DiagnosisImage.find(params[:id])
    end
    
    def set_equipment name, anchor
      equipment = Equipment.find_by equipment: name
      if equipment
        Object.const_get(equipment[:klass]).find(anchor.to_i)
      end
    rescue ActiveRecord::RecordNotFound
      nil
    end
    
    def generate_hash_code
      Digest::SHA256.hexdigest(params[:equipment] + params[:anchor] + (params[:tag] || ""))
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def diagnosis_image_params
      params[:diagnosis_image] = { authentication_key: params[:authentication_key], remote_ip: request.remote_ip.to_sym, protocol: params[:protocol], version: params[:version], equipment: params[:equipment], anchor: params[:anchor], tag: params[:tag], hash_code: generate_hash_code, image_file: params[:image_file] }
      params.require(:diagnosis_image).permit(:protocol, :version, :equipment, :anchor, :tag, :hash_code, :image_file)
    end
    
    def html_request?
      request.format.html?
    end 
end
