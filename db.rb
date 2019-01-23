require 'pg'

$conn = PG.connect(dbname: 'quizapp',
          host: 'localhost',
          user: 'quizapp',
          password: 'test'
          )

def db_use(name)
 #$conn = PG.connect dbname: name
 create_quizlist_table()
rescue PG::ConnectionBad => e
 puts "making #{name}"
 $conn.exec("create database #{name}")
 $conn = PG.connect dbname: name
 create_quizlist_table()
end
=begin
questions json
ex: {"do you like chicken?" : {"yes" : 1, "no" : 0, "maybe" : -1}}
the question is a key and the value contains another json with all answers being the keys and the values being the weights of the answers
the final result is the culmination of all the weights after all questions have been answered.
=end

def create_quizlist_table()
 #create basic quizlist table
 $conn.exec("create table if not exists quizlist(id int primary key not null, info json not null)")
 #create first quiz question table
 $conn.exec(createQuizQues(1))
 #create first quiz answer table
 $conn.exec(createQuizRes(1))
 #prepare statements, inserquiz is to insert a new quiz into quizlist. insertres is to insert new answers into quizans#{id}
 $conn.prepare('insertquiz', 'insert into quizlist (id, info) values ($1, $2)')
 $conn.prepare('insertres', insertQuizRes(1))
 $conn.prepare('insertques1', insertQuizQues(1))
 #create the first quiz
 $conn.exec_prepared('insertquiz', [1,'{ "title" : "Which disney princess are you?", "id" : 1 }'])
 $conn.exec_prepared('insertques1', ["Do you like to fight?", '{"yes" : 1, "no" : 0 }'])
 $conn.exec_prepared('insertres', [[1,1], "Mulan"])
 $conn.exec_prepared('insertres', [[0,0], "Bella"])
 #second quiz
 $conn.exec(createQuizQues(2))
 $conn.exec(createQuizRes(2))
 $conn.prepare('insertques2', insertQuizQues(2))
 $conn.exec_prepared('insertquiz', [2,'{ "title" : "Which of Ilanas pets are you?", "id" : 2 }'])
 $conn.exec_prepared('insertques2', ["Do you like to eat?", '{"yes" : 1, "no" : 0 }'])
 $conn.exec_prepared('insertques2', ["Are you a doggo or a catto?", '{"yes" : 2, "no" : 0 }'])
 $conn.exec_prepared('insertres', [[2,3], "Dante the dog"])
 $conn.exec_prepared('insertres', [[1,1], "Buddy the Cat"])
 $conn.exec_prepared('insertres', [[0,0], "Steve the cat"])


end

def insertQuizRes(id)
 temp = "insert into quizres#{id} (search, result) values ($1, $2)"
 puts temp
 return temp
end

def insertQuizQues(id)
 temp = "insert into quizques#{id} (question, answers) values ($1, $2)"
 puts temp
 return temp
end

def createQuizQues(id)
 temp = "create table if not exists quizques#{id}(question text, answers json)"
 puts temp
 return temp
end

def createQuizRes(id)
 puts id
 temp = "create table if not exists quizres#{id}(search int4range, result text)"
 puts temp
 return temp
end

db_use("quizapp")