# MySql Database

import mysql.connector

'''
mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="007Royals",
    database="my_db"
)

print(mydb)

mycursor = mydb.cursor()
mycursor.execute("CREATE DATABASE mydatabase")
mycursor.execute("create table people (id varchar(6) PRIMARY KEY, name varchar(255), sex char(1), age int, sexuality varchar(255), avg_poop_color varchar(255), animal_they_would_have_sex_with varchar(255))")

# Check if table exists
mycursor.execute("SHOW TABLES")
for x in mycursor:
  print(x)
'''


class People:
    def __init__(self):
        self.connect()
    
    def connect(self):
        print("Connecting to database...")
        self.mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            password="007Royals",
            database="my_db"
        )
        self.mycursor = self.mydb.cursor(buffered=True)
        print("Connected!")
    
    def add(self, id, name, sex, age, orient, poop, animal):
        # Add the data
        sql = f"""INSERT INTO people 
            (id, name, sex, age, sexuality, avg_poop_color, animal_they_would_have_sex_with)
             VALUES (%s, %s, %s, %s, %s, %s, %s)"""
        val = (id, name, sex, age, orient, poop, animal)
        self.mycursor.execute(sql, val)
        self.mydb.commit()

        # Get the row we just added
        self.mycursor.execute(f"select * from people where id = '{id}'")
        result = self.mycursor.fetchall()

        # Get number of rows
        self.mycursor.execute("select * from people")
        rows = self.mycursor.rowcount

        print(f'Successfully added the following row to the database.\n{name}\n  Row count: {rows}')

    def remove(self, id):
        # Get the row we are about to delete
        self.mycursor.execute(f"select * from people where id = '{id}'")
        result = self.mycursor.fetchall()

        # Delete the row
        sql = f"delete from people where id = '{id}'"
        self.mycursor.execute(sql)
        self.mydb.commit()

        # Get number of rows
        self.mycursor.execute("select * from people")
        rows = self.mycursor.rowcount

        print(f'Successfully deleted the following row from the database.\n{result}\n  Row count: {rows}')
    
    def display(self):
        self.mycursor.execute('select * from people')
        result = self.mycursor.fetchall()

        # Print column names
        num_fields = len(self.mycursor.description)
        field_names = [i[0] for i in self.mycursor.description]
        print(field_names)

        # Print all rows
        for value in result:
            print(value)
        self.mydb.commit()
    
    def check_id(self, id): # to check if an id exists in the database or not, returns true or false
        self.mycursor.execute(f"select * from people where id = '{id}'")
        result = self.mycursor.rowcount
        if result == 0:
            return False
        else:
            return True

    def check_name(self, name): # to return the rows with the same name
        self.mycursor.execute(f"select * from people where name = '{name}'")
        result = self.mycursor.fetchall()
        print(result)


    

def main():
    p = People()

    while True:
        print('')
        action = input('Enter an action (add, reomove, display, exit): ')
        print('')

        if action == 'exit':
            break

        if action == 'add':
            # Inputs
            while True: # Want to check if id is valid or if it already exists
                id = input("Enter the person's six-digit id (ex. 000001). Input: ")
                if len(id) != 6:
                    print("Invalid entry, please try again.")
                elif p.check_id(id):
                    print("Input already exists, please try again.")
                else:
                    break

            name = input("What is this person's name? Input: ")
            sex = input("Are they a male(M), female(F), or other(O)? Input: ")
            age  = int(input(f"How old is {name}? Input: "))
            orient = input(f"What is {name}'s sexual orientation? Input: ")
            poop = input(f"On an average day, what color is {name}'s poop? Input: ")
            animal = input(f"If {name} had to choose an animal to have sex with, what would it be? Input: ")

            # Add using inputs
            p.add(id, name, sex.upper(), age, orient.lower(), poop.lower(), animal.lower())
        
        if action == 'remove':
            while True:
                i = input("Do you know this person's id? Answer yes or no. Input: ")
                if i.lower() == 'yes':
                    id = input("Enter the id here. Input: ")
                    p.remove(id)
                    break

                elif i.lower() == 'no':
                    name = input("Enter the person's name. Input: ")
                    print("Here is a list of all of the people who's name is {name}.")
                    p.check_name(name)
                    id = input("Please enter the id of the person you would like to remove. Input: ")
                    p.remove(id)
                    break

                else:
                    print('Invalid answer, please try again.')
                
        
        if action == 'display':
            p.display()


if __name__ == '__main__':
    main()