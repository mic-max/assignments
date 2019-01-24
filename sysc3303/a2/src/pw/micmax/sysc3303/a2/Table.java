package pw.micmax.sysc3303.a2;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ArrayBlockingQueue;

@SuppressWarnings("serial")
public class Table extends ArrayBlockingQueue<Ingredient> {

	public Table() {
		super(2);
	}

	public synchronized void add(List<Ingredient> items) {
		while (!isEmpty()) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		addAll(items);
		notifyAll();
	}

	public synchronized List<Ingredient> removeAll() {
		while (isEmpty()) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		List<Ingredient> items = new ArrayList<>(this);
		clear();
		notifyAll();
		return items;
	}
}
