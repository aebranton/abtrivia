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

q = Question.create(question_category: cat_sports, question: "Which player holds the record for most consecutive MLB games played?")
Answer.create(question: q, correct: true, answer: "Cal Ripken Jr.")
Answer.create(question: q, correct: false, answer: "Stan Musial")
Answer.create(question: q, correct: false, answer: "Pete Rose")
Answer.create(question: q, correct: false, answer: "Lou Gehrig")

q = Question.create(question_category: cat_sports, question: "Which of these teams has never won an NBA championship?")
Answer.create(question: q, correct: true, answer: "Indiana Pacers")
Answer.create(question: q, correct: false, answer: "Milwaukee Bucks")
Answer.create(question: q, correct: false, answer: "Houston Rockets")
Answer.create(question: q, correct: false, answer: "New York Knocks")

q = Question.create(question_category: cat_sports, question: "What jersey number did Wayne Gretzky wear?")
Answer.create(question: q, correct: false, answer: "1")
Answer.create(question: q, correct: false, answer: "9")
Answer.create(question: q, correct: false, answer: "27")
Answer.create(question: q, correct: true, answer: "99")

cat_math = QuestionCategory.find_by(name: "Math")

q = Question.create(question_category: cat_math, question: "What is 15^2?")
Answer.create(question: q, correct: false, answer: "30")
Answer.create(question: q, correct: false, answer: "252")
Answer.create(question: q, correct: true, answer: "225")
Answer.create(question: q, correct: false, answer: "15")

q = Question.create(question_category: cat_math, question: "How do you calculate the area of a circle?")
Answer.create(question: q, correct: false, answer: "Diameter * 3")
Answer.create(question: q, correct: true, answer: "pi * r^2")
Answer.create(question: q, correct: false, answer: "(Radius * 4) / pi")
Answer.create(question: q, correct: false, answer: "pi * r")

q = Question.create(question_category: cat_math, question: "What is the top number of a fraction called?")
Answer.create(question: q, correct: true, answer: "Numerator")
Answer.create(question: q, correct: false, answer: "Denominator")
Answer.create(question: q, correct: false, answer: "Ruler")
Answer.create(question: q, correct: false, answer: "Standard")

q = Question.create(question_category: cat_math, question: "What amount does the \"Giga\" prefix stand for?")
Answer.create(question: q, correct: false, answer: "One Trillion")
Answer.create(question: q, correct: false, answer: "One Million")
Answer.create(question: q, correct: true, answer: "One Billion")
Answer.create(question: q, correct: false, answer: "One Zillion")

cat_sci = QuestionCategory.find_by(name: "Science")

q = Question.create(question_category: cat_sci, question: "Which planet is nearest the sun?")
Answer.create(question: q, correct: false, answer: "Venus")
Answer.create(question: q, correct: false, answer: "Mars")
Answer.create(question: q, correct: false, answer: "Neptune")
Answer.create(question: q, correct: true, answer: "Mercury")

q = Question.create(question_category: cat_sci, question: "Which is the hottest planet in the solar system?")
Answer.create(question: q, correct: false, answer: "Mercury")
Answer.create(question: q, correct: false, answer: "Mars")
Answer.create(question: q, correct: true, answer: "Venus")
Answer.create(question: q, correct: false, answer: "Pluto")

q = Question.create(question_category: cat_sci, question: "Electrons can have be \"up\" or \"down\" in this term scientists use:")
Answer.create(question: q, correct: true, answer: "Spin")
Answer.create(question: q, correct: false, answer: "Velocity")
Answer.create(question: q, correct: false, answer: "Angle")
Answer.create(question: q, correct: false, answer: "Standing")

q = Question.create(question_category: cat_sci, question: "How long does a human red blood cell survive?")
Answer.create(question: q, correct: false, answer: "3 days")
Answer.create(question: q, correct: false, answer: "Your entire life")
Answer.create(question: q, correct: true, answer: "120 days")
Answer.create(question: q, correct: false, answer: "3 years")

cat_his = QuestionCategory.find_by(name: "History")

q = Question.create(question_category: cat_his, question: "How many years did the 100 years war last?")
Answer.create(question: q, correct: true, answer: "116 years")
Answer.create(question: q, correct: false, answer: "100 years")
Answer.create(question: q, correct: false, answer: "98 years")
Answer.create(question: q, correct: false, answer: "127 years")

q = Question.create(question_category: cat_his, question: "Greenland was a colony of which country until 1981?")
Answer.create(question: q, correct: false, answer: "Norway")
Answer.create(question: q, correct: true, answer: "Denmark")
Answer.create(question: q, correct: false, answer: "Iceland")
Answer.create(question: q, correct: false, answer: "Germany")

q = Question.create(question_category: cat_his, question: "How many days in a week were there in ancient Roman times?")
Answer.create(question: q, correct: false, answer: "6")
Answer.create(question: q, correct: false, answer: "7")
Answer.create(question: q, correct: true, answer: "8")
Answer.create(question: q, correct: false, answer: "14")

q = Question.create(question_category: cat_his, question: "How did Alexander the Great solve the puzzle of the Gordion knot?")
Answer.create(question: q, correct: false, answer: "Knowledge from Boy Scouts")
Answer.create(question: q, correct: false, answer: "Carefully studying paths")
Answer.create(question: q, correct: false, answer: "Burned it to ash")
Answer.create(question: q, correct: true, answer: "Cut it with a sword")

cat_music = QuestionCategory.find_by(name: "Music")

q = Question.create(question_category: cat_music, question: "Rock band AC/DC actually originates from which country?")
Answer.create(question: q, correct: true, answer: "Australia")
Answer.create(question: q, correct: false, answer: "New Zealand")
Answer.create(question: q, correct: false, answer: "Aruba")
Answer.create(question: q, correct: false, answer: "USA")

q = Question.create(question_category: cat_music, question: "Who is the lead singer of Pearl Jam?")
Answer.create(question: q, correct: false, answer: "Thom Yorke")
Answer.create(question: q, correct: false, answer: "Gord Downiw")
Answer.create(question: q, correct: true, answer: "Eddie Vedder")
Answer.create(question: q, correct: false, answer: "John Yukel")

q = Question.create(question_category: cat_music, question: "The Grateful Dead’s highly-devoted fanbase is known as what?")
Answer.create(question: q, correct: false, answer: "Zombies")
Answer.create(question: q, correct: false, answer: "Walking Dead")
Answer.create(question: q, correct: true, answer: "Deadheads")
Answer.create(question: q, correct: false, answer: "The Grateful Ones")

q = Question.create(question_category: cat_music, question: "The Rock and Roll Hall of Fame is situated in what US State?")
Answer.create(question: q, correct: false, answer: "New York")
Answer.create(question: q, correct: true, answer: "Ohio")
Answer.create(question: q, correct: false, answer: "Massachusettes")
Answer.create(question: q, correct: false, answer: "Idaho")

cat_assurance = QuestionCategory.find_by(name: "Assurance")

q = Question.create(question_category: cat_assurance, question: "Which of these does Assurance NOT offer?")
Answer.create(question: q, correct: false, answer: "Health Insurance")
Answer.create(question: q, correct: false, answer: "Auto Insurance")
Answer.create(question: q, correct: true, answer: "Investing Advice")
Answer.create(question: q, correct: false, answer: "Personal Loans")

q = Question.create(question_category: cat_assurance, question: "What is Assurance's rating from the Better Businss Bureau?")
Answer.create(question: q, correct: false, answer: "10/10")
Answer.create(question: q, correct: false, answer: "B+")
Answer.create(question: q, correct: true, answer: "A+")
Answer.create(question: q, correct: false, answer: "Excellent")

q = Question.create(question_category: cat_assurance, question: "Which of the following is not something Assurance uses to better thier services?")
Answer.create(question: q, correct: false, answer: "Data Science")
Answer.create(question: q, correct: false, answer: "Live Agents")
Answer.create(question: q, correct: true, answer: "Cold-Call Marketing")
Answer.create(question: q, correct: false, answer: "Online Tools")

q = Question.create(question_category: cat_assurance, question: "Who is the CEO of Assurance?")
Answer.create(question: q, correct: true, answer: "Michael Rowell")
Answer.create(question: q, correct: false, answer: "Allison (O'Hair) Arzeno")
Answer.create(question: q, correct: false, answer: "Mike Paulus")
Answer.create(question: q, correct: false, answer: "Will Arora")

cat_assurance = QuestionCategory.find_by(name: "Alex Branton")

q = Question.create(question_category: cat_assurance, question: "Which of these is NOT a language Alex knows?")
Answer.create(question: q, correct: false, answer: "c++")
Answer.create(question: q, correct: false, answer: "ruby")
Answer.create(question: q, correct: false, answer: "python")
Answer.create(question: q, correct: true, answer: "None of these")

q = Question.create(question_category: cat_assurance, question: "Why would Alex be a great fit for Assurance?")
Answer.create(question: q, correct: false, answer: "He is humble and always wanting to learn")
Answer.create(question: q, correct: false, answer: "He works well with a team")
Answer.create(question: q, correct: false, answer: "He is an effective developer")
Answer.create(question: q, correct: true, answer: "All of these")

q = Question.create(question_category: cat_assurance, question: "If Alex gets offered a position at Assurance, it would be:")
Answer.create(question: q, correct: false, answer: "A huge mistake")
Answer.create(question: q, correct: false, answer: "A short-term position")
Answer.create(question: q, correct: false, answer: "Cool")
Answer.create(question: q, correct: true, answer: "Beneficial for everyone!")