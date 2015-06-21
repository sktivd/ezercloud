# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Equipment.create!(equipment: 'FREND', manufacturer: "NanoEnTek", klass: "Frend")
AssayKit.create!(id: 1, equipment: 'FREND', manufacturer: "NanoEnTek", device: "PSA plus", kit_id: 30)
Reagent.create!(name: 'PSA (Total)', number: 30, assay_kit_id: 1)
AssayKit.create!(id: 2, equipment: 'FREND', manufacturer: "NanoEnTek", device: "TSH", kit_id: 40)
Reagent.create!(name: 'TSH', number: 40, assay_kit_id: 2)
AssayKit.create!(id: 3, equipment: 'FREND', manufacturer: "NanoEnTek", device: "BNP", kit_id: 19)
Reagent.create!(name: 'BNP', number: 19, assay_kit_id: 3)
AssayKit.create!(id: 4, equipment: 'FREND', manufacturer: "NanoEnTek", device: "Cardiac Triple", kit_id: 15)
Reagent.create!(name: 'Myoglobin', number: 14, assay_kit_id: 4)
Reagent.create!(name: 'Troponin I', number: 12, assay_kit_id: 4)
Reagent.create!(name: 'CK-MB', number: 13, assay_kit_id: 4)
