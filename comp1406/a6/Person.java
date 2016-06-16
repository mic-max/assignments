/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

import java.util.*;

public class Person {

	private final String name;
	private LibraryBook[] books;

	public Person(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public LibraryBook[] getLibraryBooks() {
		return books;
	}

	public void addBook(LibraryBook b) {
		List<LibraryBook> temp;
		if(books != null)
			temp = new ArrayList<LibraryBook>(Arrays.asList(books));
		else
			temp = new ArrayList<LibraryBook>();
		temp.add(b);
		books = temp.toArray(new LibraryBook[temp.size()]);
	}

	public Book[] overDueBooks(int[] date) {
		List<Book> overdue = new ArrayList<Book>();
		for(LibraryBook lb : books) {
			int[] due = lb.dueDate();
			if(due[0] + 31 * (due[1] + 12 * due[2]) < date[0] + 31 * (date[1] + 12 * date[2]))
				overdue.add(new Book(lb.getName(), lb.getAuthor()));
		}
		return overdue.toArray(new Book[overdue.size()]);
	}
}