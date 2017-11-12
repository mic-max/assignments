package comp2402a3;

import java.util.Random;
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;

public class Tester {

	public static <T> boolean tableEquals(Table<T> t1, Table<T> t2) {
		if (t1.rows() != t2.rows())
			return false;
		if (t1.cols() != t2.cols())
			return false;
		for (int i = 0; i < t1.rows(); i++) {
			for (int j = 0; j < t2.cols(); j++) {
				T x1 = t1.get(i, j);
				T x2 = t2.get(i, j);
				if (x1 != null && x2 == null)
					return false;
				if (x1 == null && x2 != null)
					return false;
				if (x1 != null && !x1.equals(x2))
					return false;
			}
		}
		return true;
	}

	public static boolean tableCorrectness(Table<Integer> t) {
		Random r = new Random();
		A2Table<Integer> t2 = new A2Table<Integer>(Integer.class);
		for(int i = 0; i < 69; i++) {
			t.addRow(0);
			t2.addRow(0);
		}
		for(int i = 0; i < 6969; i++) {
			t.addCol(i);
			t2.addCol(i);
		}
		for(int i = 0; i < 6969; i++) {
			int j = r.nextInt(t.rows());
			int k = r.nextInt(t.cols());
			int x = r.nextInt();
			t.set(j, k, x);
			t2.set(j, k, x);
		}
		for(int i = 0; i < 7; i++) {
			int k = r.nextInt(t.rows());
			t.removeRow(k);
			t2.removeRow(k);
		}
		for(int i = 0; i < 69; i++) {
			int k = r.nextInt(t.cols());
			t.removeCol(k);
			t2.removeCol(k);
		}
		if(!tableEquals(t, t2))
			return false;
		return true;
	}

	public static boolean listCorrectness(List<Integer> l) {
		Random r = new Random();
		List<Integer> l2 = new DumbDefaultList<Integer>();

		final int N = 30000;
		for(int i = 0; i < 2500; i++) {
			int j = r.nextInt(N);
			int x = r.nextInt(N);
			l.add(j, x);
			l2.add(j, x);
			Integer a = l.get(j);
			Integer b = l2.get(j);
			if(a != null && b != null && !a.equals(b))
				return false;
			//System.out.printf("added to lists at %d = %d \n", j , x);
			///
			j = r.nextInt(N);
			x = r.nextInt(N);
			l.set(j, x);
			l2.set(j, x);
			a = l.get(j);
			b = l2.get(j);
			if(a != null && b != null && !a.equals(b))
				return false;
			//System.out.printf("set lists at %d = %d \n", j , x);
			///
			j = r.nextInt(N);
			a = l.remove(j);
			b = l2.remove(j);
			if(a != null && b != null && !a.equals(b))
				return false;
			//System.out.printf("removed from lists at %d \n", j);
		}

		for(int i = 0; i < N; i++) {
			Integer a = l.get(i);
			Integer b = l2.get(i);
			if(a != null && b != null) {
				if(!a.equals(b)) {
					//System.out.printf("%d --- a = %d, b = %d \n", i, a , b);
					return false;
				}
			}
		}

		return true;
	}

	public static boolean testPart1(Table<Integer> t) {
		if(!tableCorrectness(t))
			return false;
		return true;
	}

	public static void testTable(Table<Integer> tab) {
		long start = System.nanoTime();
		boolean result = Tester.testPart1(tab);
		long stop = System.nanoTime();
		double elapsed = (stop-start)/1e9;
		System.out.printf("testPart1 returns %s in %fs when testing a %s",
			result, elapsed, tab.getClass().getName());
  }


	public static boolean testPart2(List<Integer> ell) {
		if(!listCorrectness(ell))
			return false;
		return true;
	}

	public static void testDefaultList(List<Integer> ell) {
		long start = System.nanoTime();
		boolean result = Tester.testPart2(ell);
		long stop = System.nanoTime();
		double elapsed = (stop-start)/1e9;
		System.out.printf("testPart2 returns %s in %fs when testing a %s",
			result, elapsed, ell.getClass().getName());
  }

}
