package comp2402a2;

import java.util.*;

public class Treque<T> extends AbstractList<T> {
	protected List<T> tail, head;

	public Treque(Class<T> t) {
		tail = new ArrayDeque<T>(t);
		head = new ArrayDeque<T>(t);
	}

	public T get(int i) {
		if (i < 0 || i > size() - 1)
			throw new IndexOutOfBoundsException();

		if(i < tail.size())
			return tail.get(i);
		return head.get(i - tail.size());
	}

	public T set(int i, T x) {
		if (i < 0 || i > size() - 1)
			throw new IndexOutOfBoundsException();
		
		if(i < tail.size())
			return tail.set(i, x);
		return head.set(i - tail.size(), x);
	}

	public void add(int i, T x) {
		if (i < 0 || i > size())
			throw new IndexOutOfBoundsException();
		
		balance();
		if(i > tail.size())
			head.add(i - tail.size(), x);
		else
			tail.add(i, x);
	}

	public T remove(int i) {
		if (i < 0 || i > size() - 1)
			throw new IndexOutOfBoundsException();

		balance();
		if(i < tail.size())
			return tail.remove(i);
		else
			return head.remove(i - tail.size());
	}

	public int size() {
		return tail.size() + head.size();
	}

	private void balance() {
		final int n = 2;
		
		if(head.size() + n < tail.size()) {
			head.add(0, tail.remove(tail.size() - 1));
		} else if(tail.size() + n < head.size()) {
			tail.add(head.remove(0));
		}
	}

	public static void main(String[] args) {
		List<Integer> tr = new Treque<Integer>(Integer.class);
		
		int K = 100000;
		Stopwatch s = new Stopwatch();
		System.out.print("Appending " + K + " items...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			tr.add(i);
			//ad.add(i);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Prepending " + K + " items...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			tr.add(0, i);
			//ad.add(0, i);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Midpending(?!) " + K + " items...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			tr.add(tr.size()/2, i);
			//ad.add(tr.size()/2, i);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");


		System.out.print("Removing " + K + " items from the back...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			tr.remove(tr.size()-1);
			//ad.remove(tr.size()-1);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Removing " + K + " items from the front...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			tr.remove(0);
			//ad.remove(0);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Removing " + K + " items from the middle...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			tr.remove(tr.size()/2);
			//ad.remove(tr.size()/2);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");
	}
}