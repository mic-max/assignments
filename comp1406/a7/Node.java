/*
  Student Name:   Michael Maxwell
  Student Number:   101006277
  References:     I did not use any reference material in developing this assignment.
*/

public class Node{
  private Person person;
  private Node   next;
  
  /* constructors */

  /** Create an empty node */
  public Node(){
    this.person = null;
    this.next = null;
  }

  /** Create a node with person specified by name and age */
  public Node(String name, int age){
    this.person = new Person(name, age);
    this.next = null;
  }
  
  /** create a node with a given person */
  public Node(Person person){
    this.person = person;
    this.next = null;
  }
  
  
  /* getters */
  
  /** Date getter (Person) */
  public Person getPerson(){ return this.person; }
  
  /** Next node getter */
  public Node getNext(){ return this.next; }
  
  
  /* setters */
  
  /** Person setter */
  public void setPerson(Person person){ this.person = person; }
  
  /** Next node setter */
  public void setNext(Node next){ this.next = next; }
  
  
}