/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class LibraryBook {

	private Book book;
	private int[] date;
	private Person checkedOutBy;

	public LibraryBook(Book b) {
		book = b;
	}

	public String getName() {
		return book.getName();
	}

	public String getAuthor() {
		return book.getAuthor();
	}

	public String checkedOutBy() {
		return checkedOutBy.getName();
	}

	public boolean isCheckedOut() {
		return checkedOutBy != null;
	}

	public void checkOut(Person p, int[] date) {
		checkedOutBy = p;
		this.date = date;
		p.addBook(this);
	}

	public int[] dueDate() {
		int[] due = {-1, -1, -1};
		if(isCheckedOut()) {
			due[0] = date[0];
			due[1] = (date[1] + 1) % 12;
			due[2] = date[2] + date[1] / 12;
		}
		return due;
	}
}