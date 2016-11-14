module EncryptionKey
  extend ActiveSupport::Concern  
  
  def encryption_key
    raise 'ATTR_ENCRYPTED_KEY environmental variable is prerequisite!' if Rails.env.production? and ENV['TOKEN_KEY'].nil?
    ENV['ATTR_ENCRYPTED_KEY'] || 'test_key'
  end
  
end
