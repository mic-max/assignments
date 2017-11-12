package comp2402a2;

import java.util.*;

public class Table<T> implements AbstractTable<T> {
	protected List<List<T>> list;
	protected int cols;

	public Table(Class<T> t) {
		list = new ArrayList<List<T>>();
		cols = 0;
	}

	public int rows() {
		return list.size();
	}

	public int cols() {
		return cols;
	}

	public T get(int i, int j) {
		if (i < 0 || i > rows() - 1 || j < 0 || j > cols() - 1)
			throw new IndexOutOfBoundsException();
		
		return list.get(i).get(j);
	}

	public T set(int i, int j, T x) {
		if (i < 0 || i > rows() - 1 || j < 0 || j > cols() - 1)
			throw new IndexOutOfBoundsException();
		
		return list.get(i).set(j, x);
	}

	public void addRow(int i) {
		if (i < 0 || i > rows())
			throw new IndexOutOfBoundsException();

		// add a row with the current number of columns
		list.add(i, new ArrayList<T>());

		// need to set everything to null
		for(int j = 0; j < cols(); j++)
			list.get(i).add(null);
	}

	public void removeRow(int i) {
		if (i < 0 || i > rows() - 1)
			throw new IndexOutOfBoundsException();
		
		list.remove(i);
	}

	public void addCol(int j) {
		if (j < 0 || j > cols())
			throw new IndexOutOfBoundsException();

		cols++;
		for(List<T> row: list)
			row.add(j, null);
	}

	public void removeCol(int j) {
		if (j < 0 || j > cols() - 1)
			throw new IndexOutOfBoundsException();
		
		cols--;
		for(List<T> row : list)
			row.remove(j);
	}

	public String toString() {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < rows(); i++) {
			for (int j = 0; j < cols(); j++) {
				sb.append(String.valueOf(get(i, j)));
				sb.append(" ");
			}
			sb.append("\n");
		}
		return sb.toString();
	}

	/* Here is the expected output from this main function:
		1111 null null null null null 
		null 2222 null null null null
		null null 3333 null null null
		null null null 4444 null null
		null null null null 5555 null
		null null null null null 6666
		7777 null null null null null
		null 8888 null null null null
		null null 9999 null null null

		1111 null null null null null null
		null 2222 null null null null null
		null null null 3333 null null null
		null null null null null null null
		null null null null 4444 null null
		null null null null null 5555 null
		null null null null null null 6666
		7777 null null null null null null
		null 8888 null null null null null
		null null null 9999 null null null
	*/
	public static void main(String[] args) {
		int nrows = 9, ncols = 6;
		Table<Integer> t = new Table<Integer>(Integer.class);

		for (int i = 0; i < ncols; i++) {
			//System.out.printf("t.addCol(t.cols()); : t.addCol(%d)\n", t.cols());
			//System.out.printf("Size (%d, %d)\n", t.rows(), t.cols());
			t.addCol(t.cols());
		}

		for (int i = 0; i < nrows; i++) {
			//System.out.printf("t.addRow(t.rows()); : t.addRow(%d)\n", t.rows());
			//System.out.printf("Size (%d, %d)\n", t.rows(), t.cols());
			t.addRow(t.rows());
		}

		for (int i = 1; i <= nrows; i++) {
			//System.out.printf("t.set(i - 1, (i - 1) %% t.cols(), 1111 * i); : t.set(%d, %d, %d);\n", i - 1, (i - 1) % t.cols(), 1111 * i);
			t.set(i - 1, (i - 1) % t.cols(), 1111 * i);
		}

		System.out.println(t.toString());
		t.addCol(2);
		t.addRow(3);
		System.out.println(t.toString());
	}
}