json.array!(@notifications) do |notification|
  json.extract! notification, :id, :notification_type, :sent_at, :notified_at, :reaction_type, :content
  json.url notification_url(notification, format: :json)
end
