class ReagentManagementWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high_priority
  sidekiq_options retry:5
  
  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
  
  # The current retry count is yielded. The return value of the block must be 
  # an integer. It is used as the delay, in seconds. 
  sidekiq_retry_in do |count|
    10 * (count + 1) # (i.e. 10, 20, 30, 40)
  end
  
  def perform options
    options           = JSON.parse options.to_json, symbolize_names: true
    
    equipment         = Equipment.find_by equipment: options[:name]
    new_measurement   = Object.const_get(equipment[:klass]).find(options[:id])
    assay_kit         = AssayKit.find_by equipment: options[:name], kit: options[:kit]
    
    processed         = true
    measured_reagents = new_measurement[(equipment.prefix + 'id').to_sym].split(':', -1).map { |value| value.to_i }
    values            = new_measurement[(equipment.prefix + 'result').to_sym].split(':', -1)
    assay_kit.reagents.each do |reagent|
      if (index = measured_reagents.index(reagent.number))
        qcms        = reagent.quality_control_materials
        new_insert  = {service: options[:service], lot: options[:lot], expire: options[:expire], equipment: options[:name], manufacturer: new_measurement.manufacturer, reagent_name: reagent.name, reagent_number: reagent.number}
        value       = values[index].to_f

        if (qcm = qcms.find_by(service: options[:service], lot: options[:lot])).nil?
          new_insert.merge!({n_equipment: 1, n_measurement: 1, mean: value, sd: nil})
          processed &= reagent.quality_control_materials.create(new_insert)
        else
          n = qcm.n_measurement + 1
          mean = (qcm.mean * qcm.n_measurement + value) / n
          if qcm.sd
            sd = Math.sqrt((qcm.n_measurement * (qcm.sd ** 2)- n * ( qcm.mean - mean) ** 2 + (value - mean) ** 2) / n)
          else
            sd = [qcm.mean, value].sd
          end
          new_insert.merge!({n_equipment: qcm.n_equipment + (Object.const_get(equipment[:klass]).find_by(serial_number: new_measurement.serial_number) ? 0 : 1), n_measurement: n, mean: mean, sd: sd})
          processed &= qcm.update(new_insert)
        end
      end
    end
    
    processed
  end

end
