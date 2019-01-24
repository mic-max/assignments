package pw.micmax.sysc3303.a2;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

public class Producer implements Runnable {

	private static final int N = 20;

	private Table table;

	public Producer(Table table) {
		this.table = table;
	}

	@Override
	public void run() {
		// Places all but one ingredient on the table, 20 times.
		for (int i = 0; i < N; i++) {
			List<Ingredient> items = new ArrayList<>();
			Collections.addAll(items, Ingredient.values());
			items.remove(ThreadLocalRandom.current().nextInt(items.size()));

			table.add(items);
			System.out.println(" << " + items);
		}
	}
}
