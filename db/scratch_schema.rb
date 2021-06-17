# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_24_122931) do

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "analyses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: true
    t.string "ancestry"
    t.index ["ancestry"], name: "index_analyses_on_ancestry"
  end

  create_table "analysis_disciplines", force: :cascade do |t|
    t.bigint "discipline_id"
    t.bigint "analysis_id"
    t.index ["analysis_id"], name: "index_analysis_disciplines_on_analysis_id"
    t.index ["discipline_id"], name: "index_analysis_disciplines_on_discipline_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "container_type"
    t.integer "container_id"
    t.string "data_file_name"
    t.string "data_content_type"
    t.bigint "data_file_size"
    t.datetime "data_updated_at"
    t.string "description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_type", "container_id"], name: "index_attachments_on_container_type_and_container_id"
  end

  create_table "cases", force: :cascade do |t|
    t.integer "operation_id"
    t.integer "variable_id"
    t.integer "coord_index", default: -1
    t.text "values"
  end

  create_table "connections", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.string "role", default: ""
    t.index ["from_id"], name: "index_connections_on_from_id"
    t.index ["to_id"], name: "index_connections_on_to_id"
  end

  create_table "design_project_filings", force: :cascade do |t|
    t.integer "design_project_id"
    t.integer "analysis_id"
    t.index ["analysis_id"], name: "index_design_project_filings_on_analysis_id"
    t.index ["design_project_id"], name: "index_design_project_filings_on_design_project_id"
  end

  create_table "design_projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "disciplines", force: :cascade do |t|
    t.string "name"
    t.integer "analysis_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "position"
    t.index ["analysis_id"], name: "index_disciplines_on_analysis_id"
  end

  create_table "distributions", force: :cascade do |t|
    t.string "kind", null: false
    t.integer "variable_id"
    t.index ["variable_id"], name: "index_distributions_on_variable_id"
  end

  create_table "endpoints", force: :cascade do |t|
    t.string "host"
    t.integer "port"
    t.string "service_type"
    t.integer "service_id"
    t.index ["service_type", "service_id"], name: "index_endpoints_on_service_type_and_service_id"
  end

  create_table "geometry_models", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string "status"
    t.text "log"
    t.integer "pid", default: -1
    t.integer "operation_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "sqlite_filename"
    t.integer "log_count", default: 0
  end

  create_table "meta_model_prototypes", force: :cascade do |t|
    t.integer "meta_model_id"
    t.integer "prototype_id"
    t.index ["meta_model_id"], name: "index_meta_model_prototypes_on_meta_model_id"
    t.index ["prototype_id"], name: "index_meta_model_prototypes_on_prototype_id"
  end

  create_table "meta_models", force: :cascade do |t|
    t.integer "discipline_id"
    t.integer "operation_id"
    t.string "default_surrogate_kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discipline_id"], name: "index_meta_models_on_discipline_id"
    t.index ["operation_id"], name: "index_meta_models_on_operation_id"
  end

  create_table "openmdao_analysis_impls", force: :cascade do |t|
    t.boolean "parallel_group"
    t.integer "analysis_id"
    t.integer "nonlinear_solver_id"
    t.integer "linear_solver_id"
    t.index ["analysis_id"], name: "index_openmdao_analysis_impls_on_analysis_id"
    t.index ["linear_solver_id"], name: "index_openmdao_analysis_impls_on_linear_solver_id"
    t.index ["nonlinear_solver_id"], name: "index_openmdao_analysis_impls_on_nonlinear_solver_id"
  end

  create_table "openmdao_discipline_impls", force: :cascade do |t|
    t.boolean "implicit_component"
    t.boolean "support_derivatives"
    t.integer "discipline_id"
    t.index ["discipline_id"], name: "index_openmdao_discipline_impls_on_discipline_id"
  end

  create_table "operations", force: :cascade do |t|
    t.integer "analysis_id"
    t.string "name"
    t.string "host", default: ""
    t.string "driver", default: "runonce"
    t.text "success"
    t.integer "base_operation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "optimizations", force: :cascade do |t|
    t.string "kind"
    t.text "config"
    t.text "inputs"
    t.text "outputs"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "options", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.integer "operation_id"
    t.string "optionizable_type"
    t.integer "optionizable_id"
    t.index ["operation_id"], name: "index_options_on_operation_id"
    t.index ["optionizable_type", "optionizable_id"], name: "index_options_on_optionizable_type_and_optionizable_id"
  end

  create_table "parameters", force: :cascade do |t|
    t.text "init"
    t.text "lower"
    t.text "upper"
    t.integer "variable_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "scalings", force: :cascade do |t|
    t.integer "variable_id"
    t.string "ref", default: ""
    t.string "ref0", default: ""
    t.string "res_ref", default: ""
    t.index ["variable_id"], name: "index_scalings_on_variable_id"
  end

  create_table "solvers", force: :cascade do |t|
    t.string "name"
    t.float "atol"
    t.float "rtol"
    t.integer "maxiter"
    t.integer "iprint"
    t.boolean "err_on_non_converge"
  end

  create_table "surrogates", force: :cascade do |t|
    t.integer "meta_model_id"
    t.integer "variable_id"
    t.integer "coord_index"
    t.string "kind"
    t.string "status"
    t.text "quality"
    t.index ["meta_model_id"], name: "index_surrogates_on_meta_model_id"
    t.index ["variable_id"], name: "index_surrogates_on_variable_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.text "settings"
    t.boolean "deactivated"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "variables", force: :cascade do |t|
    t.string "name"
    t.integer "discipline_id"
    t.string "io_mode"
    t.string "type"
    t.string "shape"
    t.string "units"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["discipline_id"], name: "index_variables_on_discipline_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "analysis_disciplines", "analyses"
  add_foreign_key "analysis_disciplines", "disciplines"
end
