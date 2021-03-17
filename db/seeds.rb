# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Been a while so will note this for myself.
# Now, to effectively reset the DB after some testing:
# rails db:drop:_unsafe
# rails db:create
# rails db:migrate
# rails db:seed
# The last 3 are just there for completeness, but really the drop:_unsafe was what i missed

QuestionCategory.create([
    {name: "Sports"},
    {name: "Math"},
    {name: "Science"},
    {name: "History"},
    {name: "Music"},
    {name: "Assurance"},
    {name: "Alex Branton"},
])

TriviaSessionState.create([
    {name: "Pending"},
    {name: "Active"},
    {name: "Ended"}
])

Player.create(display_name: "Alex Branton", email: "ae.branton9@gmail.com")

# math questions
cat_sports = QuestionCategory.find_by(name: "Sports")

q = Question.create(question_category: cat_sports, question: "The Toronto NHL team is called the \"Toronto Maple ...\"")
Answer.create(question: q, correct: false, answer: "Trees")
Answer.create(question: q, correct: false, answer: "Cookies")
Answer.create(question: q, correct: true, answer: "Leafs")
Answer.create(question: q, correct: false, answer: "Leaves")

q = Question.create(question_category: cat_sports, question: "Which NHL Team won the Stanley Cup during the covid-quarantined playoffs in the 2019-2020 season?")
Answer.create(question: q, correct: false, answer: "Dallas Stars")
Answer.create(question: q, correct: true, answer: "Tampa Bay Lightning")
Answer.create(question: q, correct: false, answer: "Detroit Red Wings")
Answer.create(question: q, correct: false, answer: "Pitsburgh Penguins")

cat_math = QuestionCategory.find_by(name: "Math")

q = Question.create(question_category: cat_math, question: "What is 15^2?")
Answer.create(question: q, correct: false, answer: "30")
Answer.create(question: q, correct: false, answer: "252")
Answer.create(question: q, correct: true, answer: "225")
Answer.create(question: q, correct: false, answer: "15")