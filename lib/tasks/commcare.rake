require 'commcare_api'
require 'open-uri'

namespace :commcare do
  
  COMMCARE_VERSION        = 1
  PERSON_VERSION          = 1
  COMMCARE_IMAGE_VERSION  = 1
  
  IMAGE_EXTENSION_NAMES   = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']
                           
  PROJECT_NAME            = "ezerproject"
  
  STUDENT_APP_ID          = "fe20cd0fee28354baa479cd1c043c739"
  STUDENT_START_DATE      = "2016-10-01" # survey form was almost fixed at 2016-10-01.
  
  desc 'get new (Capetown, South Africa) student survey items from CommCareHQ'
  task get_student_surveys: :environment do
    puts "---------- Start at " + DateTime.now.to_s + " ----------"
    
    date_on_recent_survey = (Commcare.order(:received_at).last.received_at.strftime('%FT%T.%6N') if Commcare.last) || STUDENT_START_DATE
    puts "----------  Check from #{date_on_recent_survey}"
    # receive newly updated surveys
    ccc = CommcareApi::CommcareConnector.new(ENV['COMMCARE_USERNAME'], ENV['COMMCARE_PASSWORD'])
    response = ccc.get_forms(PROJECT_NAME, received_on_start: date_on_recent_survey || STUDENT_START_DATE, limit: 20)
    
    while ! response.nil? do 
      body = JSON.parse(response.body, symbolize_names: true)
      break if body[:objects].nil?
      body[:objects].each do |object|

        # find only student survey
        if object[:app_id] == STUDENT_APP_ID && object[:type] == "data"
          puts object[:type] + " : " + (object[:form][:"@name"] || "") + " : " + (object[:form][:uniq_id] || "")
          attachment_url = "https://www.commcarehq.org/a/ezerproject/api/form/attachment/" + object[:id]
          Commcare.transaction do
            begin
              @commcare = Commcare.new version: COMMCARE_VERSION, app_id: STUDENT_APP_ID, form: object[:id], name: object[:form][:"@name"], measured_at: object[:form][:meta][:timeEnd], received_at: object[:received_on], raw: object.to_json
  
              # match person
              @person = Person.find_person(object[:form][:uniq_id])
              # new registration            
              if @person.nil? && object[:form][:uniq_id]
                @person = Person.create! version: PERSON_VERSION, person: object[:form][:uniq_id]
              end              
              # update student information
              if object[:form][:"@name"] == "Student Registration" 
                @person.given_name  = object[:form][:personal][:given_name]  if object[:form][:personal][:given_name]
                @person.family_name = object[:form][:personal][:family_name] if object[:form][:personal][:family_name]
                @person.sex         = object[:form][:personal][:gender]      if object[:form][:personal][:gender]
                @person.birthday    = object[:form][:personal][:birth_year]  if object[:form][:personal][:birth_year]
                @person.id_photo    = open(attachment_url + "/" + object[:form][:personal][:picture], http_basic_authentication: [ENV['COMMCARE_USERNAME'], ENV['COMMCARE_PASSWORD']]) if IMAGE_EXTENSION_NAMES.include?(File.extname(object[:form][:personal][:picture]))
                @person.save!
              end
              
              @commcare.person = @person
              @commcare.agreement_signature = object[:form][:Consent][:signature] if object[:form][:Consent] && object[:form][:Consent][:signature] &&  IMAGE_EXTENSION_NAMES.include?(File.extname(object[:form][:Consent][:signature]))
              @commcare.agreement_signature = object[:form][:Consent][:gurdian_signature] if object[:form][:Consent] && object[:form][:Consent][:gurdian_signature] && IMAGE_EXTENSION_NAMES.include?(File.extname(object[:form][:Consent][:gurdian_signature]))
              @commcare.save!
            
              # process attached images
              if object[:attachments]
                object[:attachments].each do |attachment, properties|
                  if properties[:content_type] =~ /\Aimage\/.*\z/
                    @commcare_image = CommcareImage.new name: attachment.to_s, version: COMMCARE_IMAGE_VERSION, commcare: @commcare
                    @commcare_image.image_file = open(attachment_url + "/" + attachment.to_s, http_basic_authentication: [ENV['COMMCARE_USERNAME'], ENV['COMMCARE_PASSWORD']])
                    @commcare_image.save!
                  end
                end
              end
            rescue ActiveRecord::RecordInvalid => invalid
              puts "skip #{invalid.record.form}: #{invalid.record.errors.messages}"
            end
          end
        end
      end
      
      # receive remained surveys
      response = ccc.get_next_data
    end
    
    puts "---------- Done at " + DateTime.now.to_s + " ----------"
  end
  
end
