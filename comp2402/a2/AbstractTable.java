package comp2402a2;

/**
 */
public interface AbstractTable<T> {
    /**
    * Number of rows in table
    */
	public int rows();

    /**
    * Number of columns in table
    */
	public int cols();

    /**
    * get element located at row i and column j
    */
	public T get(int i, int j);

    /**
    * set element located at row i and column j
    * to x
    */
	public T set(int i, int j, T x);

    /**
    * add Row at index i
    */
	public void addRow(int i);

    /**
    * remove Row at index i
    */
	public void removeRow(int i);

    /**
    * add Column at index j
    */
	public void addCol(int j);

    /**
    * remove Column at index j
    */
	public void removeCol(int j);
}
