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

ActiveRecord::Schema.define(version: 2021_03_22_001900) do

  create_table "answers", force: :cascade do |t|
    t.integer "question_id"
    t.text "answer"
    t.boolean "correct", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "player_answers", force: :cascade do |t|
    t.integer "player_id"
    t.integer "trivia_session_id"
    t.integer "answer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "question_id"
  end

  create_table "player_trivia_session_records", force: :cascade do |t|
    t.integer "player_id"
    t.integer "trivia_session_id"
    t.boolean "victory", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "email"
    t.string "display_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "question_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer "question_category_id"
    t.text "question"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trivia_session_questions", force: :cascade do |t|
    t.integer "trivia_session_id"
    t.integer "question_id"
    t.integer "question_index"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trivia_session_states", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trivia_sessions", force: :cascade do |t|
    t.integer "player_id"
    t.integer "min_players", default: 2
    t.integer "trivia_session_state_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
