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

ActiveRecord::Schema.define(version: 20150621034749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assay_kits", force: :cascade do |t|
    t.string   "equipment"
    t.string   "manufacturer"
    t.integer  "kit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "device"
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
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "sex",              default: -1
    t.integer  "age_band",         default: -1
    t.string   "order_number"
    t.integer  "diagnosable_id"
    t.string   "diagnosable_type"
  end

  add_index "diagnoses", ["diagnosable_type", "diagnosable_id"], name: "index_diagnoses_on_diagnosable_type_and_diagnosable_id", using: :btree

  create_table "equipment", force: :cascade do |t|
    t.string   "equipment"
    t.string   "manufacturer"
    t.string   "klass"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "external_quality_controls", force: :cascade do |t|
    t.string   "equipment"
    t.integer  "device_id"
    t.integer  "test_id"
    t.string   "sample_type"
    t.string   "reagent"
    t.string   "lot_number"
    t.datetime "expired_at"
    t.string   "unit"
    t.float    "mean"
    t.float    "sd"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "frends", force: :cascade do |t|
    t.integer  "version"
    t.string   "manufacturer"
    t.string   "serial_number"
    t.integer  "test_type"
    t.boolean  "processed"
    t.string   "error_code"
    t.integer  "device_id"
    t.integer  "device_ln"
    t.integer  "test0_id"
    t.integer  "test1_id"
    t.integer  "test2_id"
    t.float    "test0_result"
    t.float    "test1_result"
    t.float    "test2_result"
    t.integer  "test0_integral"
    t.integer  "test1_integral"
    t.integer  "test2_integral"
    t.integer  "control_integral"
    t.integer  "test0_center_point"
    t.integer  "test1_center_point"
    t.integer  "test2_center_point"
    t.integer  "control_center_point"
    t.float    "average_background"
    t.integer  "measured_points"
    t.text     "point_intensities"
    t.string   "external_qc_service_id"
    t.string   "external_qc_catalog"
    t.string   "external_qc_ln"
    t.decimal  "external_qc_level"
    t.boolean  "internal_qc_laser_power_test"
    t.boolean  "internal_qc_laseralignment_test"
    t.boolean  "internal_qc_calcaulated_ratio_test"
    t.boolean  "internal_qc_test"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "reagents", force: :cascade do |t|
    t.string   "name"
    t.integer  "number"
    t.integer  "assay_kit_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "reagents", ["assay_kit_id"], name: "index_reagents_on_assay_kit_id", using: :btree

  add_foreign_key "reagents", "assay_kits"
end
