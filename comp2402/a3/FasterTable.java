package comp2402a3;

import java.util.*;

public class FasterTable<T> implements Table<T> {
	List<List<T>> tab;
	List<Integer> col;
	int nrows, ncols;

	public FasterTable(Class<T> t) {
		tab = new ArrayList<List<T>>();
		col = new ArrayList<Integer>();
		nrows = 0;
		ncols = 0;
	}

	public int rows() { return nrows; }
	public int cols() { return ncols; }

	public T get(int i, int j) {
		if (i < 0 || i > rows() - 1 || j < 0 || j > cols()-1)
			throw new IndexOutOfBoundsException();

		int k = col.get(j);
		return tab.get(i).get(k);
	}

	public T set(int i, int j, T x) {
		if (i < 0 || i > rows() - 1 || j < 0 || j > cols()-1)
			throw new IndexOutOfBoundsException();

		int k = col.get(j);
		return tab.get(i).set(k, x);
	}

	public void addRow(int i) {
		if (i < 0 || i > rows())
			throw new IndexOutOfBoundsException();

		List<T> row = new ArrayList<T>();
		for (int j = 0; j < cols(); j++) {
			row.add(null);
		}
		tab.add(i, row);
		nrows++;
	}

	public void removeRow(int i) {
		if (i < 0 || i > rows() - 1)
			throw new IndexOutOfBoundsException();

		tab.remove(i);
		nrows--;
	}

	public void addCol(int j) {
		if (j < 0 || j > cols())
			throw new IndexOutOfBoundsException();
		
		for(int i = 0; i < rows(); i++) {
			tab.get(i).add(null);
		}

		col.add(j, cols());
		ncols++;
	}

	public void removeCol(int j) {
		if (j < 0 || j > cols() - 1)
			throw new IndexOutOfBoundsException();

		col.remove(j);
		ncols--;
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

	public static void main(String[] args) {
		FasterTable<Integer> t = new FasterTable<Integer>(Integer.class);
		Tester.testPart1(t);
	}
}