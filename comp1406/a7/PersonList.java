/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/


public class PersonList {

	private Node head;

	public PersonList() {}

	public PersonList(Person p){
		head = new Node(p);
	}

	public int size() {
		int s = 0;
		for(Node c = head; c != null; c = c.getNext(), s++);
		return s;
	}

	public PersonList add(Person p) {
		return add(p, 0);
	}

	public PersonList add(Person p, int position) {
		Node n = new Node(p);

		if(position == 0) {
			n.setNext(head);
			head = n;
		} else {
			Node c = head;
			for(int i = 1; i < position; c = c.getNext(), i++);
			n.setNext(c.getNext());
			c.setNext(n);
		}

		return this;
	}

	public PersonList add(PersonList people, int startPosition) {
		Node c = head;
		Node q = people.head;

		for(int i = 0; i < startPosition; c = c.getNext(), i++);
		for(int i = startPosition; q != null; q = q.getNext(), i++)
			add(q.getPerson(), i);

		return this;
	}

	public int findPosition(Person p) {
		Node c = head;

		for(int i = 0; c != null; c = c.getNext(), i++) {
			Person q = c.getPerson();
			if(p.getAge() == q.getAge() && p.getName().equals(q.getName()))
				return i;
		}

		return -1;
	}

	public Person personAt(int position) {
		Node c = head;
		for(int i = 0; i < position; c = c.getNext(), i++);
		return c.getPerson();
	}

	public Person remove(int position) {
		if(head == null)
			return null;

		Node c = head;
		Person p;

		if(position == 0) {
			p = c.getPerson();
			head = c.getNext();
		} else {
			for(int i = 1; i < position; c = c.getNext(), i++);
			p = c.getNext().getPerson();
			c.setNext(c.getNext().getNext());
		}

		return p;
	}

	public PersonList remove(int startPosition, int endPosition) {
		PersonList p = new PersonList();
		Node c = head;

		for(int i = 0; i < startPosition; c = c.getNext(), i++);
		for(int i = startPosition; i < endPosition; c = c.getNext(), i++) {
			p.add(c.getPerson(), p.size());
			remove(startPosition);
		}

		return p;
	}

	public boolean sameAs(PersonList otherList) {
		if(size() != otherList.size())
			return false;

		Node a, b;

		for(a = head, b = otherList.head; a != null; a = a.getNext(), b = b.getNext()) {
			Person p = a.getPerson();
			Person q = b.getPerson();
			if(p.getAge() != q.getAge() || !p.getName().toLowerCase().equals(q.getName().toLowerCase()))
				return false;
		}

		return true;
	}

	public PersonList olderThan(int age) {
		PersonList p = new PersonList();

		for(Node c = head; c != null; c = c.getNext()) {
			Person q = c.getPerson();
			if(q.getAge() > age)
				p.add(q, p.size());
		}

		return p;
	}

	public String toString() {
		String s = "[";
		Node c = head;
		for(; c != null; c = c.getNext()) {
			Person p = c.getPerson();
			s += String.format("%s(%d)", p.getName(), p.getAge());
			if(c.getNext() != null)
				s += ", ";
		}
		return s + "]";
	} 
}