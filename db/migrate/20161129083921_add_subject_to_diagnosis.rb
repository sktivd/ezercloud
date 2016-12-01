class AddSubjectToDiagnosis < ActiveRecord::Migration[5.0]
  def change
    add_reference :diagnoses, :subject, index: true
    
    Diagnosis.find_each do |diagnosis|
      if diagnosis.person
        @person = Person.find_person diagnosis.person
        if @person.nil?
          @person = Person.create version: Person::PERMITTED_VERSION.last, person: diagnosis.person
        end
        diagnosis.update(subject: @person) 
      end
    end
  end
end
