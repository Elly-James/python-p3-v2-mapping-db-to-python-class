Introduction
The previous lesson showed how to implement methods to persist (i.e. save) the attributes of a Python object as a row in a database table.

In this lesson, we see how to map the opposite direction, namely we will map the values stored in a database table row to the attributes of a Python object. We will implement the following methods:

Method	Return	Description
instance_from_db (cls, row)	object that is an instance of cls	Return an object that is an instance of the class, assigning the attribute values from a table row
get_all (cls)	a list containing objects that are instances of cls	Return a list of objects that are instances of the class, assigning the attribute values from each row in a table.
find_by_id(cls, id))	object that is an instance of cls	Return an object that is an instance of the class, assigning the attribute values using the table row specified by the primary key id
find_by_name(cls, name)	object that is an instance of cls	Return an object that is an instance of the class, assigning the attribute values using the first table row matching the specified name




Maintaining a dictionary of objects persisted to the database
Several of the methods we write in this lesson will query the "departments" table and return a department object whose attributes are assigned to the row data. However, consider what happens if we query the table several times for the same table row. For example, we may have 10 employees working for the same department. Within our Python application, we will have 10 employee objects that should all be associated with the same department object. It is important that we avoid creating duplicate department objects when mapping from the same "departments" table row.

To solve this, we will cache (i.e. store) each department object that has been persisted to the database. We'll use a dictionary data structure, where each entry consists of a key and a value:

the key is the id of the Python object that was saved to the database (i.e. an instance of the Department class).
the value is the actual Python object that was saved to the database.
In later lessons we will use an ORM framework named FLASK-SQLALCHEMY, which manages the mapping between table rows and Python objects, and alleviates the need to explicitly maintain a dictionary in our code.

Let's update the Department class to add a class variable named all that references a dictionary to store each Department object that has been saved to the database.


instance_from_db()
Method	Return	Description
instance_from_db (cls, row)	object that is an instance of cls	Return an object that is an instance of the class, assigning the attribute values from a table row
This method will map the data stored in a "deparments" table row into an instance of Department.

One thing to know is that the database, SQLite in our case, will return a list of data for each row. For example, a row for the payroll department would look like this: [1, "Payroll", "Building A, 5th Floor"]. We use row[0] to get the department id 1, row[1] to get the department name "Payroll", etc.

Add the new class method instance_from_db(cls, row) to the Department class





Type exit() to terminate the debugging session, then rerun python lib/debug.py to create the table with initial values. We can list the dictionary of persisted objects:

ipdb> Department.all
{1: <Department 1: Payroll, Building A, 5th Floor>, 2: <Department 2: Human Resources, Building C, East Wing>, 3: <Department 3: Accounting, Building B, 1st Floor>}
Execute a query to get a row of data, then use that row to get a Python Department object (type each statement one at a time at the prompt ipdb>):

ipdb> row = CURSOR.execute("select * from departments").fetchone()
ipdb> row
(1, 'Payroll', 'Building A, 5th Floor')
ipdb> department = Department.instance_from_db(row)
ipdb> department
<Department 1: Payroll, Building A, 5th Floor>
ipdb>





get_all()
Method	Return	Description
get_all (cls)	a list containing objects that are instances of cls	Return a list of objects that are instances of the class, assigning the attribute values from each row in a table.
To return all the departments in the database, we need to do the following:

define a SQL query statement to select all rows from the table
use the CURSOR to execute the query, and then call the fetchall() method on the query result to return the rows sequentially in a tuple.
iterate over each row and call instance_from_db() with each row in the query result to retrieve a Python object from the row data:
Add the new class method get_all() to the Department class:



Exit ipdb and run python lib/debug.pyagain and follow along in theipdb` session:

ipdb> Department.get_all()
[<Department 1: Payroll, Building A, 5th Floor>, <Department 2: Human Resources, Building C, East Wing>, <Department 3: Accounting, Building B, 1st Floor>]
ipdb>
Success! We can see all three departments in the database as a list of Department instances. We can interact with them just like any other Python objects:

ipdb> departments = Department.get_all()
ipdb> departments[0]
<Department 1: Payroll, Building A, 5th Floor>
ipdb> departments[0].name
'Payroll'
ipdb>




find_by_id()
Method	Return	Description
find_by_id(cls, id))	object that is an instance of cls	Return an object that is an instance of the class, assigning the attribute values using the table row specified by the primary key id
This one is similar to get_all(), with the small exception being that we have a WHERE clause to test the id in our SQL statement. To do this, we use a bound parameter (i.e. question mark) where we want the id parameter to be passed in, and we include id in a tuple as the second argument to the execute() method:


Let's try out this new method. Exit ipdb and run python lib/debug.py again:

ipdb> department = Department.find_by_id(1)
ipdb> department
<Department 1: Payroll, Building A, 5th Floor>
ipdb> department.name
'Payroll'
ipdb> department.location
'Building A, 5th Floor'
ipdb>



find_by_name()
Method	Return	Description
find_by_name(cls, name)	object that is an instance of cls	Return an object that is an instance of the class, assigning the attribute values using the first table row matching the specified name
The find_by_name() method is similar to find_by_id(), but we will limit the result to the first row matching the specified name.


Let's try out this new method. Exit ipdb and run python lib/debug.py again:

ipdb> department = Department.find_by_name("Payroll")
ipdb> department
<Department 1: Payroll, Building A, 5th Floor>


Update the delete method to remove the dictionary entry
The delete method deletes the table row corresponding to the current Department instance. To ensure the Python object model reflects the table data, the delete method should also remove the corresponding key/value pair from the dictionary, and assign the instance id attribute back to None.

Update the delete method as shown: