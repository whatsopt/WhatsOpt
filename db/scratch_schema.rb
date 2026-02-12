# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_12_100000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: :integer, default: nil, force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :integer, default: nil, force: :cascade do |t|
    t.integer "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "analyses", force: :cascade do |t|
    t.string "ancestry"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "locked", default: false
    t.string "name"
    t.boolean "public", default: true
    t.datetime "updated_at", precision: nil, null: false
    t.index ["ancestry"], name: "index_analyses_on_ancestry"
  end

  create_table "analysis_disciplines", id: :integer, default: nil, force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "discipline_id"
    t.index ["analysis_id"], name: "index_analysis_disciplines_on_analysis_id"
    t.index ["discipline_id"], name: "index_analysis_disciplines_on_discipline_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "category"
    t.integer "container_id"
    t.string "container_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "data_content_type"
    t.string "data_file_name"
    t.bigint "data_file_size"
    t.datetime "data_updated_at", precision: nil
    t.string "description"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["container_type", "container_id"], name: "index_attachments_on_container_type_and_container_id"
  end

  create_table "cases", force: :cascade do |t|
    t.integer "coord_index", default: -1
    t.integer "operation_id"
    t.text "values"
    t.integer "variable_id"
  end

  create_table "connections", force: :cascade do |t|
    t.integer "from_id"
    t.string "role", default: ""
    t.integer "to_id"
    t.index ["from_id"], name: "index_connections_on_from_id"
    t.index ["to_id"], name: "index_connections_on_to_id"
  end

  create_table "design_project_filings", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "design_project_id"
    t.index ["analysis_id"], name: "index_design_project_filings_on_analysis_id"
    t.index ["design_project_id"], name: "index_design_project_filings_on_design_project_id"
  end

  create_table "design_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "disciplines", force: :cascade do |t|
    t.integer "analysis_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.integer "position"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
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
    t.integer "service_id"
    t.string "service_type"
    t.index ["service_type", "service_id"], name: "index_endpoints_on_service_type_and_service_id"
  end

  create_table "geometry_models", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "ended_at", precision: nil
    t.text "log"
    t.integer "log_count", default: 0
    t.integer "operation_id"
    t.integer "pid", default: -1
    t.string "sqlite_filename"
    t.datetime "started_at", precision: nil
    t.string "status"
  end

  create_table "journal_details", force: :cascade do |t|
    t.string "action", limit: 30, default: "", null: false
    t.string "entity_attr", limit: 30, default: "", null: false
    t.string "entity_name", limit: 255, default: "", null: false
    t.string "entity_type", limit: 30, default: "", null: false
    t.integer "journal_id", default: 0, null: false
    t.string "old_value"
    t.string "value"
    t.index ["journal_id"], name: "index_journal_details_on_journal_id"
  end

  create_table "journals", force: :cascade do |t|
    t.integer "analysis_id", default: 0, null: false
    t.datetime "created_on", precision: nil, null: false
    t.integer "user_id", default: 0, null: false
    t.index ["analysis_id"], name: "index_journals_on_analysis_id"
    t.index ["user_id"], name: "index_journals_on_user_id"
  end

  create_table "openmdao_analysis_impls", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "linear_solver_id"
    t.integer "nonlinear_solver_id"
    t.string "optimization_driver"
    t.string "package_name"
    t.boolean "parallel_group"
    t.boolean "use_units"
    t.index ["analysis_id"], name: "index_openmdao_analysis_impls_on_analysis_id"
    t.index ["linear_solver_id"], name: "index_openmdao_analysis_impls_on_linear_solver_id"
    t.index ["nonlinear_solver_id"], name: "index_openmdao_analysis_impls_on_nonlinear_solver_id"
  end

  create_table "openmdao_discipline_impls", force: :cascade do |t|
    t.integer "discipline_id"
    t.boolean "egmdo_surrogate", default: false, null: false
    t.boolean "implicit_component"
    t.boolean "jax_component", default: false, null: false
    t.boolean "support_derivatives"
    t.index ["discipline_id"], name: "index_openmdao_discipline_impls_on_discipline_id"
  end

  create_table "operations", force: :cascade do |t|
    t.integer "analysis_id"
    t.integer "base_operation_id"
    t.datetime "created_at", precision: nil
    t.string "driver", default: "runonce"
    t.string "host", default: ""
    t.string "name"
    t.text "success"
    t.datetime "updated_at", precision: nil
  end

  create_table "options", force: :cascade do |t|
    t.string "name"
    t.integer "operation_id"
    t.integer "optionizable_id"
    t.string "optionizable_type"
    t.string "value"
    t.index ["operation_id"], name: "index_options_on_operation_id"
    t.index ["optionizable_type", "optionizable_id"], name: "index_options_on_optionizable_type_and_optionizable_id"
  end

  create_table "packages", force: :cascade do |t|
    t.integer "analysis_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_packages_on_analysis_id"
  end

  create_table "parameters", force: :cascade do |t|
    t.text "init"
    t.text "lower"
    t.text "upper"
    t.integer "variable_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "scalings", force: :cascade do |t|
    t.string "ref", default: ""
    t.string "ref0", default: ""
    t.string "res_ref", default: ""
    t.integer "variable_id"
    t.index ["variable_id"], name: "index_scalings_on_variable_id"
  end

  create_table "solvers", force: :cascade do |t|
    t.float "atol"
    t.boolean "err_on_non_converge"
    t.integer "iprint"
    t.integer "maxiter"
    t.string "name"
    t.float "rtol"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.boolean "deactivated"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "login", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.text "settings"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "variables", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.string "desc"
    t.integer "discipline_id"
    t.string "io_mode"
    t.string "name"
    t.string "shape"
    t.string "type"
    t.string "units"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discipline_id"], name: "index_variables_on_discipline_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "analysis_disciplines", "analyses"
  add_foreign_key "analysis_disciplines", "disciplines"
  add_foreign_key "packages", "analyses"
end
