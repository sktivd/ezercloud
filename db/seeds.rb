# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Desirable Biological Variation Database specifications: https://www.westgard.com/biodatabase1.htm

#u = User.create(name: "admin", password: "11112222", full_name: "Administrator", privilege_super: true, email: "skonmeme@gmail.com", authorized: true)
#u = User.create(name: "reagent", password: "22221111", full_name: "Reagent Manager for FREND", email: "skonmemekr@gmail.com", privilege_reagent: true, privilege_notification: true, equipment_frends: true, authorized: true)

# Equipment

e_frend = Equipment.create(equipment: 'FREND', manufacturer: 'NanoEnTek', klass: 'Frend', db: 'frends', tests: 3, prefix: 'test_')
e_buddi = Equipment.create(equipment: 'BUDDI', manufacturer: 'NanoEnTek', klass: 'Buddi', db: 'buddis', tests: 6, prefix: 'test_')
e_ezer_reader = Equipment.create(equipment: 'EzerReader', manufacturer: 'Unknown', klass: 'EzerReader', db: 'ezer_readers', tests: 6, prefix: 'test_')

# Assay kits & QC materials

r11 = Reagent.create(equipment: 'FREND', name: 'QC', number: 11, unit: 'NA')
r12 = Reagent.create(equipment: 'FREND', name: 'Troponin I', number: 12, unit: 'ng/mL', lod: 0.05, uod: 20, threshold: 0.4)
r13 = Reagent.create(equipment: 'FREND', name: 'CK-MB', number: 13, unit: 'ng/mL', lod: 1, uod: 80, threshold: 5)
r14 = Reagent.create(equipment: 'FREND', name: 'Myoglobin', number: 14, unit: 'ng/mL', lod: 5, uod: 500, threshold: 100)
r16 = Reagent.create(equipment: 'FREND', name: 'hsCRP', number: 16, unit: 'ng/mL', lod: 0.3, uod: 10, threshold: 1)
r17 = Reagent.create(equipment: 'FREND', name: 'D-Dimer', number: 17, unit: 'ng/mL', lod: 0, uod: 3000, threshold: 300)
r18 = Reagent.create(equipment: 'FREND', name: 'NT-proBNP', number: 18, unit: 'pg/mL', lod: 5, uod: 35000, threshold: 125)
r19 = Reagent.create(equipment: 'FREND', name: 'BNP', number: 19, unit: 'pg/mL', lod: 30, uod: 2500, threshold: 125)
r20 = Reagent.create(equipment: 'FREND', name: 'FABP', number: 20, unit: 'ng/mL', lod: 2, uod: 3000, threshold: 6)
r30 = Reagent.create(equipment: 'FREND', name: 'PSA', number: 30, unit: 'ng/mL', lod: 0.1, uod: 25, threshold: 4)
r32 = Reagent.create(equipment: 'FREND', name: 'AFP', number: 32, unit: 'ng/mL', lod: 1, uod: 400, threshold: 20)
r34 = Reagent.create(equipment: 'FREND', name: 'CEA', number: 34, unit: 'ng/mL', lod: 1, uod: 400, threshold: 10)
r35 = Reagent.create(equipment: 'FREND', name: 'Testosterone', number: 35, unit: 'ng/dL', lod: 20, uod: 1500, threshold: 10)
r40 = Reagent.create(equipment: 'FREND', name: 'TSH', number: 40, unit: 'mIU/L', lod: 0.06, uod: 25, threshold: 3.33)
r41 = Reagent.create(equipment: 'FREND', name: 'Free T4', number: 41, unit: 'ng/dL', lod: 0.4, uod: 6, threshold: 1)
r42 = Reagent.create(equipment: 'FREND', name: 'Total T3', number: 42, unit: 'ng/mL', lod: 0.25, uod: 8, threshold: 1)
r43 = Reagent.create(equipment: 'FREND', name: 'Free T3', number: 43, unit: 'pg/mL', lod: 1, uod: 30, threshold: 1)
r44 = Reagent.create(equipment: 'FREND', name: 'Total T4', number: 44, unit: 'nmol/L', lod: 12.87, uod: 308.88, threshold: 1)
r50 = Reagent.create(equipment: 'FREND', name: 'Vitamin D', number: 50, unit: 'ng/mL', lod: 10, uod: 110, threshold: 20)
r60 = Reagent.create(equipment: 'FREND', name: 'PCT', number: 60, unit: 'ng/mL', lod: 0.07, uod: 32, threshold: 1)
r70 = Reagent.create(equipment: 'FREND', name: 'SAA', number: 70, unit: 'mg/L', lod: 5, uod: 150, threshold: 10)
r75 = Reagent.create(equipment: 'FREND', name: 'Hp', number: 75, unit: 'mg/dL', lod: 30, uod: 400, threshold: 50)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'QC', kit: 11)
p = r11.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Cardiac Triple', kit: 15)
p = r12.plates.create(assay_kit: a)
p = r13.plates.create(assay_kit: a)
p = r14.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'hsCRP', kit: 16)
p = r16.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'D-Dimer', kit: 17)
p = r17.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'NT-proBNP', kit: 18)
p = r18.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'BNP', kit: 19)
p = r19.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'FABP', kit: 20)
p = r20.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Cardiac Duo', kit: 21)
p = r12.plates.create(assay_kit: a)
p = r19.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'PSA plus', kit: 30)
p = r30.plates.create(assay_kit: a)
p.quality_control_materials.create(service: 'BIO-RAD', lot: '40881', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', mean: 0.270, sd: (0.270 - 0.190) / 3)
p.quality_control_materials.create(service: 'BIO-RAD', lot: '40882', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', mean: 3.95, sd: (3.95 - 3.37) / 3)
p.quality_control_materials.create(service: 'BIO-RAD', lot: '40883', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', mean: 25, sd: 0)

#a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'PAC', kit: 31)
#p = r30.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'AFP', kit: 32)
p = r32.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'CEA', kit: 34)
p = r34.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Testosterone', kit: 35)
p = r35.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'TSH', kit: 40)
p = r40.plates.create(assay_kit: a)
p.quality_control_materials.create(service: 'BIO-RAD', lot: '40881', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', mean: 0.630, sd: (0.630 - 0.440) / 3)
p.quality_control_materials.create(service: 'BIO-RAD', lot: '40882', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', mean: 5.99, sd: (5.99 - 5.08) / 3)
p.quality_control_materials.create(service: 'BIO-RAD', lot: '40883', expire: Date.new(2017, 2, 28), equipment: 'FREND', manufacturer: 'NanoEnTek', mean: 25, sd: 0)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Free T4', kit: 41)
p = r41.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Total T3', kit: 42)
p = r42.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Free T3', kit: 43)
p = r43.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Total T4', kit: 44)
p = r44.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Thyroid Duo', kit: 45)
p = r41.plates.create(assay_kit: a)
p = r40.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Vitamin D', kit: 50)
p = r50.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'PCT', kit: 60)
p = r60.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'SAA', kit: 70)
p = r70.plates.create(assay_kit: a)

a = AssayKit.create(equipment: 'FREND', manufacturer: 'NanoEnTek', device: 'Hp', kit: 75)
p = r75.plates.create(assay_kit: a)

# Labaoratories
l = Laboratory.create(ip_address: '211.210.64.61', equipment: 'FREND', kit: 30)
l = Laboratory.create(ip_address: '211.210.64.61', equipment: 'FREND', kit: 40)
l = Laboratory.create(ip_address: '58.226.94.194', equipment: 'FREND', kit: 30)
l = Laboratory.create(ip_address: '58.226.94.194', equipment: 'FREND', kit: 40)

# Error codes for FREND

c = e_frend.error_codes.create(error_code: 'EMCI-01', description: 'The cartridge is not inserted.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMCI-02', description: 'The cartridge is not inserted completely.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMCI-03', description: 'The cartridge is inserted in the oppsite direction.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMCI-04', description: 'The cartridge is inserted upside-down.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMBR-01', description: 'The barcode printed on the cartridge may have been damaged so the reader is unable to interpret the code correctly.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMBR-02', description: 'The barcode information related to the cartridge lot number printed on the cartridge is not readable by the system reader.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMBR-03', description: 'The lot number entered for the cartridge does not match the lot number on the code chip.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMDB-01', description: 'The USB drive version is not correct, or the USB drive is not proerly connected to the FREND(tm) System. In addition, the USB drive or USB H port has somehow been damaged.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMDB-02', description: 'A problem has been detected when attempting to transfer data from the FREND(tm) System to the USB drive.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMDS-01', description: 'The storage capacity of the FREND(tm) System to store the data has been exceed.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMCC-01', description: 'The code chip is not inserted properly, the code chip has somehow been damaged or the FREND(tm) System does not recognize the code chip.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMCC-02', description: 'The FREND(tm) System does not recognize the code chip.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-01', description: 'The lot number of the inserted cartridge is different from the lot number of the installed code chip.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-02', description: 'Unable to output a test result the reference signal is weaker than the baseline.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-03', description: 'Unable to output a test result because the reference signal is stronger than the baseline.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-04', description: 'The system cannot detect any signal.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-05', description: 'The system detects more than four signals because the cartridge is damaged.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-06', description: 'The lateral flow of the sample within the cartridge is incomplete.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-07', description: 'Time-out error', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMTF-08', description: 'The cartridge has passed the expiration date', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMUF-01', description: 'There is no executable file (FREND.exe) on the USB drive.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMUF-02', description: 'There is no executable file (FRENDUPDATE.exe) on the USB drive.', level: 'General')
c = e_frend.error_codes.create(error_code: 'EMER-01', description: 'The entry requirements are not entered.', level: 'General')
