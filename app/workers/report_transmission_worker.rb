class ReportTransmissionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high_priority
  sidekiq_options retry:5
  
  RECHECK_TIME = 1
  
  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
  
  # The current retry count is yielded. The return value of the block must be 
  # an integer. It is used as the delay, in seconds. 
  sidekiq_retry_in do |count|
    10 * (count + 1) # (i.e. 10, 20, 30, 40)
  end
  
  def perform options
    options = JSON.parse options.to_json, symbolize_names: true
    @report = Report.find(options[:id])

    report_uri = URI.parse(Report::REPORT_URI)
    report_request = Net::HTTP::Post::Multipart.new report_uri.path, "file" => UploadIO.new(File.open(@report.document.path), 'application/pdf', [@report.date.to_s, @report.equipment, @report.serial_number, @report.reagent.number.to_s].join('_') + ".pdf")
    report_response = Net::HTTP.start(report_uri.host, report_uri.port, use_ssl: report_uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(report_request)
    end
    @report.update({ transmitted_at: DateTime.now }) if report_response.kind_of? Net::HTTPSuccess
  end
  
end
