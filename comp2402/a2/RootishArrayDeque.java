package comp2402a2;

import java.util.*;

public class RootishArrayDeque<T> extends AbstractList<T> {
	protected List<T> tail, head;
	protected Class<T> t;

	public RootishArrayDeque(Class<T> t) {
		tail = new RootishArrayStack<T>(t);
		head = new RootishArrayStack<T>(t);
		this.t = t;
	}

	public T get(int i) {
		if (i < 0 || i > size() - 1)
			throw new IndexOutOfBoundsException();

		if(i < tail.size())
			return tail.get(tail.size() - 1 - i);
		return head.get(i - tail.size());
	}

	public T set(int i, T x) {
		if (i < 0 || i > size() - 1)
			throw new IndexOutOfBoundsException();
		
		if(i < tail.size())
			return tail.set(tail.size() - 1 - i, x);
		return head.set(i - tail.size(), x);
	}

	public void add(int i, T x) {
		if (i < 0 || i > size())
			throw new IndexOutOfBoundsException();

		balance();
		if(i < head.size())
			tail.add(tail.size() - i, x);
		else
			head.add(i - tail.size(), x);
	}

	public T remove(int i) {
		if (i < 0 || i > size() - 1)
			throw new IndexOutOfBoundsException();
		balance();
		if(i < tail.size())
			return tail.remove(tail.size() - 1 - i);
		return head.remove(i - tail.size());
	}

	public int size() {
		return tail.size() + head.size();
	}

	private void balance() {
		int n = size();
		if(tail.size() * 3 < head.size()) {

			List<T> newTail = new RootishArrayStack<T>(t);
			List<T> newHead = new RootishArrayStack<T>(t);

			int mid = size() / 2 - tail.size();

			newTail.addAll(head.subList(0, mid));
			Collections.reverse(newTail);
			newTail.addAll(tail);
	 		newHead.addAll(head.subList(mid, head.size()));
			tail = newTail;
			head = newHead;
		} else if(head.size() * 3 < tail.size()) {

			List<T> newTail = new RootishArrayStack<T>(t);
			List<T> newHead = new RootishArrayStack<T>(t);

			int mid = tail.size() - size() / 2;

			newTail.addAll(tail.subList(mid, tail.size()));
			newHead.addAll(tail.subList(0, mid));
			Collections.reverse(newHead);
			newHead.addAll(head);
			tail = newTail;
			head = newHead;
		}
	}

	public static void main(String[] args) {
		List<Integer> rad = new RootishArrayDeque<Integer>(Integer.class);
		int K = 1000000;
		Stopwatch s = new Stopwatch();
		System.out.print("Appending " + K + " items...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			rad.add(i);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Prepending " + K + " items...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			rad.add(0, i);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Removing " + K + " items from the back...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			rad.remove(rad.size()-1);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");

		System.out.print("Removing " + K + " items from the tail...");
		System.out.flush();
		s.start();
		for (int i = 0; i < K; i++) {
			rad.remove(0);
		}
		s.stop();
		System.out.println("done (" + s.elapsedSeconds() + "s)");
	}
}