package comp2402a2;

import java.util.*;

public class Tester {

	public static boolean testPart1(List<Integer> ell) {
		// test correctness
		List<Integer> al = new ArrayList<Integer>();
		if(!ell.equals(al))
			return false;
		for(int i = 0; i <= 10; i++) {
			al.add(0, i);
			ell.add(0, i);
			if(!ell.equals(al))
				return false;
		}
		for(int i = 11; i <= 20; i++){
			al.add(i);
			ell.add(i);
			if(!ell.equals(al))
				return false;
		}
		for(int i = 21; i <= 30; i++){
			al.add(al.size() / 2, i);
			ell.add(ell.size() / 2, i);
			if(!ell.equals(al))
				return false;
		}

		al.set(0, 666);
		ell.set(0, 666);
		al.set(al.size() / 2, 69);
		ell.set(ell.size() / 2, 69);
		if( al.remove(16) != ell.remove(16))
			return false;

		if(al.size() != ell.size())
			return false;

		if(!ell.equals(al))
			return false;

		// test speed
		
		int K = 100000;
		for (int i = 0; i < K; i++)
			ell.add(i);

		for (int i = 0; i < K; i++)
			ell.add(0, i);

		for (int i = 0; i < K; i++)
			ell.add(ell.size() / 2 - 2, i);

		for (int i = 0; i < K; i++)
			ell.remove(ell.size() - 1);

		for (int i = 0; i < K; i++)
			ell.remove(ell.size() / 2 - 2);
		for (int i = 0; i < K; i++)
			ell.remove(0);

		
		return true;
	}

	public static boolean testPart2(List<Integer> rad) {
		// test correctness
		List<Integer> al = new ArrayList<Integer>();

		for(int i = 0; i <= 10; i++) {
			al.add(0, i);
			rad.add(0, i);
			if(!rad.equals(al))
				return false;
		}
		for(int i = 11; i <= 20; i++){
			al.add(i);
			rad.add(i);
			if(!rad.equals(al))
				return false;
		}
		
		al.set(0, 666);
		rad.set(0, 666);

		if(al.size() != rad.size())
			return false;

		if(!rad.equals(al))
			return false;
		//test performance
		
		int K = 100000;
		for (int i = 0; i < K; i++)
			rad.add(i);
		for (int i = 0; i < K; i++)
			rad.add(0, i);

		// check space efficiency


		for (int i = 0; i < K; i++)
			rad.remove(rad.size()-1);

		for (int i = 0; i < K; i++)
			rad.remove(0);
		
		// wasted space
		// if you fill the empty arrays and then convert to an []


		return true;
	}

	public static boolean testPart3(AbstractTable<Integer> t) {
		// test correctness
		int nrows = 600, ncols = 100;
		AbstractTable<Integer> table = new Table<Integer>(Integer.class);

		for (int i = 0; i < ncols; i++) {
			t.addCol(t.cols());
			table.addCol(table.cols());
		}

		for (int i = 0; i < nrows; i++) {
			t.addRow(t.rows());
			table.addRow(table.rows());
		}

		for (int i = 1; i <= nrows; i++) {
			t.set(i - 1, (i - 1) % t.cols(), 1111 * i);
			table.set(i - 1, (i - 1) % table.cols(), 1111 * i);
		}

		if(t.cols() != table.cols() || t.rows() != table.rows())
			return false;

		if(!table.toString().equals(t.toString()))
			return false;

		t.addCol(2);
		table.addCol(2);
		t.addRow(3);
		table.addRow(3);

		if(!table.toString().equals(t.toString()))
			return false;

		return true;
	}

	public static void main(String[] args) {
		System.out.println(testPart1(new Treque(Integer.class)));
		System.out.println(testPart2(new RootishArrayDeque(Integer.class)));
		System.out.println(testPart3(new Table(Integer.class)));
	}
}