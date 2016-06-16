/*
  Student Name:   Michael Maxwell
  Student Number:   101006277
  References:     I did not use any reference material in developing this assignment.
*/


public class Person{
  /** Person's name */
  private final String name; 
  
  /** Person's age */
  private int age;
  
  
  /** Create a person with given name and age */
  public Person(String name, int age){
    this.name = name;
    this.age = age;
  }
  
  /** Getter for person's name */
  public String getName(){ return this.name; }
  
  /** Getter for person's age */
  public int getAge(){ return this.age; }
  
  /** Setter for person's age */
  public void setAge(int age){ this.age = age; }
  
}
    
  