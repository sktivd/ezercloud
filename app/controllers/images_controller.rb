class ImagesController < ApplicationController
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :html_request?
  skip_before_action :authorize, only: [:create]
  before_action only: [:new, :update, :edit, :destroy] do
    allow_only_to :super
  end

  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @equipment = set_equipment(params[:equipment], params[:anchor])
    if @equipment
      STDERR.puts image_params      
      @image = @equipment.images.build(image_params)
      if @image.save
        render :created, status: :created, location: @image, formats: [:json]
      else
        @image.errors.add(:response, "fail")
        render json: @image.errors, status: :unprocessable_entity
      end
#      respond_to do |format|
#        if @image.save
#          format.html { redirect_to @image, notice: 'Image was successfully created.' }
#          format.json { render :show, status: :created, location: @image }
#        else
#          format.html { render :new }
#          format.json { render json: @image.errors, status: :unprocessable_entity }
#        end
#      end
    else
      render json: { equipment: "#{params[:equipment]} \##{params[:anchor]} not exist" }
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
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
    def image_params
      params[:image] = { authentication_key: params[:authentication_key], remote_ip: request.remote_ip.to_sym, protocol: params[:protocol], version: params[:version], equipment: params[:equipment], anchor: params[:anchor], tag: params[:tag], hash_code: generate_hash_code, image_file: params[:image_file] }
      params.require(:image).permit(:protocol, :version, :equipment, :anchor, :tag, :hash_code, :image_file)
    end
    
    def html_request?
      request.format.html?
    end 
end
