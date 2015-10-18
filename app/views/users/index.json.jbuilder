json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :privilege_super, :privilege_reagent, :privilege_notification
  json.url user_url(user, format: :json)
end
