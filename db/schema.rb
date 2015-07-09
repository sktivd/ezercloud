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

ActiveRecord::Schema.define(version: 20150628031030) do

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

  create_table "frends", force: :cascade do |t|
    t.integer  "version"
    t.string   "manufacturer"
    t.string   "serial_number"
    t.integer  "test_type"
    t.boolean  "processed",                          default: false, null: false
    t.string   "error_code"
    t.integer  "device_id"
    t.integer  "device_lot"
    t.integer  "test_id0"
    t.integer  "test_id1"
    t.integer  "test_id2"
    t.float    "test_result0"
    t.float    "test_result1"
    t.float    "test_result2"
    t.integer  "test_integral0"
    t.integer  "test_integral1"
    t.integer  "test_integral2"
    t.integer  "control_integral"
    t.integer  "test_center_point0"
    t.integer  "test_center_point1"
    t.integer  "test_center_point2"
    t.integer  "control_center_point"
    t.float    "average_background"
    t.integer  "measured_points"
    t.text     "point_intensities"
    t.string   "qc_service"
    t.string   "qc_lot"
    t.boolean  "internal_qc_laser_power_test"
    t.boolean  "internal_qc_laseralignment_test"
    t.boolean  "internal_qc_calcaulated_ratio_test"
    t.boolean  "internal_qc_test"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "quality_control_materials", force: :cascade do |t|
    t.string   "service"
    t.string   "lot_number"
    t.date     "expire"
    t.string   "equipment"
    t.string   "manufacturer"
    t.string   "reagent_name"
    t.integer  "reagent_number"
    t.string   "unit"
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

  add_foreign_key "quality_control_materials", "reagents"
  add_foreign_key "reagents", "assay_kits"
end
