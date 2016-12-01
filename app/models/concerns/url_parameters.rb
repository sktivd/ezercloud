module URLParameters
  extend ActiveSupport::Concern  

  if Rails.env == 'production'
    SCHEME = 'https'
    HOSTNAME = 'qc.ezercloud.com'
    PORT = nil
  else
    SCHEME = 'http'
    HOSTNAME = '127.0.0.1'
    PORT = 3000
  end
    
end