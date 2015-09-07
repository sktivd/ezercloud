# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150819030103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assay_kits", force: :cascade do |t|
    t.string   "equipment"
    t.string   "manufacturer"
    t.string   "device"
    t.integer  "kit"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "diagnoses", force: :cascade do |t|
    t.string   "protocol"
    t.integer  "version"
    t.string   "equipment"
    t.datetime "measured_at"
    t.float    "elapsed_time"
    t.string   "ip_address"
    t.string   "location"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "technician"
    t.integer  "sex",              default: -1
    t.integer  "age_band",         default: -1
    t.string   "order_number"
    t.integer  "diagnosable_id"
    t.string   "diagnosable_type"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "diagnoses", ["diagnosable_type", "diagnosable_id"], name: "index_diagnoses_on_diagnosable_type_and_diagnosable_id", using: :btree

  create_table "equipment", force: :cascade do |t|
    t.string   "equipment"
    t.string   "manufacturer"
    t.string   "klass"
    t.string   "db"
    t.integer  "tests"
    t.string   "prefix"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "error_codes", force: :cascade do |t|
    t.string   "error_code"
    t.string   "level"
    t.string   "description"
    t.integer  "equipment_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "error_codes", ["equipment_id"], name: "index_error_codes_on_equipment_id", using: :btree

  create_table "frends", force: :cascade do |t|
    t.integer  "version"
    t.string   "manufacturer"
    t.string   "serial_number"
    t.integer  "test_type"
    t.boolean  "processed",                         default: false, null: false
    t.string   "error_code"
    t.integer  "kit"
    t.integer  "lot"
    t.string   "test_id",                           default: "::",  null: false
    t.string   "test_result",                       default: "::",  null: false
    t.string   "integrals"
    t.string   "center_points"
    t.float    "average_background"
    t.integer  "measured_points"
    t.text     "point_intensities"
    t.string   "qc_service"
    t.string   "qc_lot"
    t.date     "qc_expire"
    t.boolean  "internal_qc_laser_power_test"
    t.boolean  "internal_qc_laseralignment_test"
    t.boolean  "internal_qc_calculated_ratio_test"
    t.boolean  "internal_qc_test"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "laboratories", force: :cascade do |t|
    t.string   "ip_address"
    t.string   "equipment"
    t.integer  "kit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quality_control_materials", force: :cascade do |t|
    t.string   "service"
    t.string   "lot"
    t.date     "expire"
    t.string   "equipment"
    t.string   "manufacturer"
    t.string   "reagent_name"
    t.integer  "reagent_number"
    t.string   "unit"
    t.integer  "n_equipment"
    t.integer  "n_measurement"
    t.float    "mean"
    t.float    "sd"
    t.integer  "reagent_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "quality_control_materials", ["reagent_id"], name: "index_quality_control_materials_on_reagent_id", using: :btree

  create_table "reagents", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.string   "unit"
    t.string   "break_points"
    t.integer  "assay_kit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "reagents", ["assay_kit_id"], name: "index_reagents_on_assay_kit_id", using: :btree

  create_table "specifications", force: :cascade do |t|
    t.string   "specimen"
    t.string   "analyte"
    t.string   "acronym"
    t.integer  "papers"
    t.float    "cv_i"
    t.float    "cv_g"
    t.float    "imprecision"
    t.float    "inaccuracy"
    t.float    "allowable_total_error"
    t.integer  "reagent_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "specifications", ["reagent_id"], name: "index_specifications_on_reagent_id", using: :btree

  add_foreign_key "error_codes", "equipment"
  add_foreign_key "quality_control_materials", "reagents"
  add_foreign_key "reagents", "assay_kits"
end
