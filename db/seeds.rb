# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

e = Equipment.create(equipment: 'FREND', manufacturer: 'NanoEnTek', klass: 'Frend', db: 'frends', variable_kit: 'device_id', variables_test_ids: 'test0_id,test1_id,test2_id', variables_test_values: 'test0_result,test1_result,test2_result', variable_qc_service: 'external_qc_service', variable_qc_lotnumber: 'external_qc_ln')

a = AssayKit.create(equipment: 'FREND', manufacturer: "NanoEnTek", device: "PSA plus", kit: 30)
r = a.reagents.create(name: 'PSA (Total)', number: 30)
q = r.quality_control_materials.create(service: 'Bio-Rad', lot_number: '40881', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: 'PSA (Total)', reagent_number: 30, unit: "ng/mL", mean: 0.270, sd: (0.270 - 0.190) / 3)
q = r.quality_control_materials.create(service: 'Bio-Rad', lot_number: '40882', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: 'PSA (Total)', reagent_number: 30, unit: "ng/mL", mean: 3.95, sd: (3.95 - 3.37) / 3)
q = r.quality_control_materials.create(service: 'Bio-Rad', lot_number: '40883', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: 'PSA (Total)', reagent_number: 30, unit: "ng/mL", mean: 25, sd: 0)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: "TSH", kit: 40)
r = a.reagents.create(name: 'TSH', number: 40)
q = r.quality_control_materials.create(service: 'Bio-Rad', lot_number: '40881', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: 'TSH', reagent_number: 40, unit: "mIU/L", mean: 0.630, sd: (0.630 - 0.440) / 3)
q = r.quality_control_materials.create(service: 'Bio-Rad', lot_number: '40882', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: 'TSH', reagent_number: 40, unit: "mIU/L", mean: 0.630, sd: (5.99 - 5.08) / 3)
q = r.quality_control_materials.create(service: 'Bio-Rad', lot_number: '40883', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', reagent_name: 'TSH', reagent_number: 40, unit: "mIU/L", mean: 25, sd: 0)


a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: "BNP", kit: 19)
r = a.reagents.create(name: 'BNP', number: 19)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Cardiac Triple', kit: 15)
r = a.reagents.create(name: 'Myoglobin', number: 14)
r = a.reagents.create(name: 'Troponin I', number: 12)
r = a.reagents.create(name: 'CK-MB', number: 13)
