class Notification < ActiveRecord::Base
  belongs_to :user
  
  validates :tag, uniqueness: { scope: [:user] }
    
  TYPES = { notice: 0, response: 1, account_validation: 2, undefined: 99 }
  RESPONSE = ["Notice", "Response", "Account Validation", "Undefined"]
  
  if Rails.env == 'production'
    SCHEME = 'https'
    HOSTNAME = 'qc.ezercloud.com'
    PORT = nil
  else
    SCHEME = 'http'
    HOSTNAME = '127.0.0.1'
    PORT = 3000
  end
  
  def uri
    URI.parse(url)
  end
  
  def set_url parameters
    controller = case follow
    when TYPES[:response], TYPES[:account_validation] 
      "/responses/"
    else 
      "/"
    end
    query = Rack::Utils.build_nested_query({authentication_key: authentication_key, redirect_path: redirect_path}.merge(parameters))
    uri = URI::HTTP.new(SCHEME, nil, HOSTNAME, PORT, nil, controller + id.to_s, nil, query, nil)
    self.url = uri.to_s
  end
  
  def parameters
    (Rack::Utils.parse_nested_query uri.query).deep_symbolize_keys
  end
    
  def path
    parameters[:path]
  end
    
  def email
    NotificationEmailWorker.perform_async(id: id)
  end  
end
