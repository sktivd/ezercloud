class Notification < ActiveRecord::Base
  resourcify
  
  belongs_to :account
  
  serialize :query, Hash
  serialize :data,  Hash
  
  RESPONSE = { notices: "Notice", responses: "Response", undefined: "Undefined" }
  AVAILABLE_NOTIFICATION_TYPES = [:notices, :responses]
  
  if Rails.env == 'production'
    SCHEME = 'https'
    HOSTNAME = 'qc.ezercloud.com'
    PORT = nil
  else
    SCHEME = 'http'
    HOSTNAME = '127.0.0.1'
    PORT = 3000
  end
  
  validates :follow, :tag, presence: true
  validates :follow, inclusion: { in: AVAILABLE_NOTIFICATION_TYPES.map { |v| v.to_s }, message: "following response is invalid" }
  validates :tag, uniqueness: { scope: [:account] }

  before_save do
    self.authentication_key = Digest::SHA256.hexdigest(self.to_s) if authentication_key.nil?
  end
  after_save :update_url, if: -> obj{ obj.url.nil? && obj.redirect_path && obj.query }
    
  def uri
    URI.parse(url) if url
  end
    
  def query_parameters
    (Rack::Utils.parse_nested_query uri.query).deep_symbolize_keys
  end
    
  def path
    parameters[:path]
  end
    
  def send_email
    NotificationEmailWorker.perform_async(id: id)
  end
  
  def send_message
  end
  
  private
    
    def update_url
      formatted_query = Rack::Utils.build_nested_query({ authentication_key: authentication_key, redirect_path: redirect_path }.merge(query))
      # scheme, userinfo, host, port, registry, path, opaque, query, fragment
      uri = URI::HTTP.new(SCHEME, nil, HOSTNAME, PORT, nil, '/' + follow + '/' + id.to_s, nil, formatted_query, nil)

      self.update(url: uri.to_s)
    end  
end
