String ObjectType = 'Case';

Type t = Type.forName(ObjectType); //Creating a type class instance

sObject newObj = (SObject)t.newInstance(); //Converting a type class instance to a SObject instance using typecasting
 //Putting value in the name field of SObject instance

insert newObj; //insert the record