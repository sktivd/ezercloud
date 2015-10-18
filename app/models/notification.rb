class Notification < ActiveRecord::Base
  belongs_to :user
  
  validates :tag, uniqueness: { scope: [:user] }
    
  TYPES = { notice: 0, response: 1, undefined: 99 }
  RESPONSE = ["Notice", "Response", "Undefined"]
  
  # SCHEME = 'https'
  # HOSTNAME = 'https://qc.ezercloud.com'
  # PORT = nil
  SCHEME = 'http'
  HOSTNAME = '127.0.0.1'
  PORT = 3000
  
  def uri
    URI.parse(url)
  end
  
  def set_url path, method, parameters
    query = Rack::Utils.build_nested_query({authentication_key: authentication_key, path: path, method: method.to_s}.merge(parameters))
    uri = URI::HTTP.new(SCHEME, nil, HOSTNAME, PORT, nil, "/responses/" + id.to_s, nil, query, nil)
    self.url = uri.to_s    
  end
  
  def parameters
    (Rack::Utils.parse_nested_query uri.query).deep_symbolize_keys
  end
    
  def path
    parameters[:path]
  end
    
  def email
    Notifier.send(mailer.to_sym, self).deliver_now
    self.update(sent_at: DateTime.now)
  end  
end
