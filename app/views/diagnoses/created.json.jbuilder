json.response "success"
json.extract! @diagnosis, :equipment, :measured_at, :ip_address, :created_at
json.hash     @equipment.id
