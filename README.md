Please note that:
------------------

- The code is for Microsoft SQL Server 2014 but it supports MS SQL 2008 R2 and 2012

- Depending on which IDE you are using, the code format and the indentation may appear funny. 
  I wrote the code by using Microsoft SQL Server 2014 Management Studio (SSMS).



Deployment instructions:
-------------------------
- Copy HQ_Data_Source on C: drive (or any other location you wihs but in that case you will
  need to manually change the location path in the 01_Load_CSV_Files.sql file).
  Also GitHub didn't allow me to add the CSV file (>25Mb) so please add the 3 CSV files.

- Go to DDL folder and run the following scripts (I used SSMS) in the following order:
   
    01_Create_Database.sql
    02_Create_Schemas.sql
    03_Create_Tables.sql    

- Go to DML and and run the following scripts (I used SSMS) in the following order:
    
    01_Load_CSV_Files.sql		<- make sure to put CSV files and format files in the correct location
    02_Initial_Load_Valid_Offers.sql
    03_Initial_Load_Hotel_Offers.sql
    04_Create_Indexes.sql
