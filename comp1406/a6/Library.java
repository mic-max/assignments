/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

import java.util.*;

public class Library {

	private LibraryBook[] bookCollection;
	private Person[] libraryUsers;

	public Library() {
	}

	public Library(LibraryBook[] books) {
		bookCollection = books;
	}

	public void addBooks(LibraryBook[] books) {
		LibraryBook[] newBookCollection = new LibraryBook[bookCollection.length + books.length];
		int len = bookCollection.length;
		for(int i = 0; i < len; i++)
			newBookCollection[i] = bookCollection[i];

		for(int i = 0; i < books.length; i++)
			newBookCollection[len + i] = books[i];
		bookCollection = newBookCollection;
	}

	public Book[] getAllBooks() {
		Book[] books = new Book[bookCollection.length];
		for(int i = 0; i < books.length; i++)
			books[i] = new Book(bookCollection[i].getName(), bookCollection[i].getAuthor());
		return books;
	}

	public Book[] getAllCheckedOutBooks() {
		List<Book> checked = new ArrayList<Book>();
		for(LibraryBook lb : bookCollection) {
			if(lb.isCheckedOut())
				checked.add(new Book(lb.getName(), lb.getAuthor()));
		}
		return checked.toArray(new Book[checked.size()]);
	}

	public Book[] getAllOverDueBooks(int[] date) {
		List<Book> overdue = new ArrayList<Book>();
		for(Person person : libraryUsers)
			Collections.addAll(overdue, person.overDueBooks(date));
		return overdue.toArray(new Book[overdue.size()]);
	}

	public boolean bookInCollection(Book b) {
		return findLibraryBook(b) != null;
	}

	public boolean isCheckedOut(Book b) {
		return findLibraryBook(b).isCheckedOut();
	}

	public Person isOverDue(Book b, int[] date) {
		LibraryBook lb = findLibraryBook(b);
		int[] due = lb.dueDate();
		if(due[0] + 31 * (due[1] + 12 * due[2]) < date[0] + 31 * (date[1] + 12 * date[2])) {
			for(Person person : libraryUsers) {
				if(person.getName().equals(lb.checkedOutBy()))
					return person;
			}
		}
		return null;
	}

	public void checkOutBook(Book b, Person p, int[] date) {
		findLibraryBook(b).checkOut(p, date);
	}

	private LibraryBook findLibraryBook(Book b) {
		for(LibraryBook lb : bookCollection) {
			if(lb.getName().equals(b.getName()) && lb.getAuthor().equals(b.getAuthor()))
				return lb;
		}
		return null;
	}
}