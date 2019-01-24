package pw.micmax.sysc3303.a2;

import java.util.*;
import java.util.concurrent.ArrayBlockingQueue;

@SuppressWarnings("serial")
public class Table extends ArrayBlockingQueue<Ingredient> {

	public Table() {
		// Create the BlockingQueue that can hold all but one of the ingredients,
		super(Ingredient.values().length);
	}

	// Waits until the queue is empty, then adds the items and notifies waiting
	// threads.
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

	// Waits until the queue has data, returns a list of all the elements before
	// clearing them.
	public synchronized List<Ingredient> removeAll() {
		while (isEmpty()) {
			try {
				wait();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		// Makes a hard copy of the current values in the queue for returning to the
		// caller.
		List<Ingredient> items = new ArrayList<>(this);
		clear();
		notifyAll();
		return items;
	}
}
