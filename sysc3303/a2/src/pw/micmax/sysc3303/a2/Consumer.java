package pw.micmax.sysc3303.a2;

import java.util.List;

public class Consumer implements Runnable {

	private Table table;
	private Thread producer;
	private final Ingredient ingredient;
	
	private long ns, nsTotal;
	private int iteration;

	// Sets up the consumer with an ingredient and references to the producer thread
	// and table.
	public Consumer(Thread producer, Table table, Ingredient ingredient) {
		this.table = table;
		this.ingredient = ingredient;
		this.producer = producer;
		
		this.ns = 0;
		this.nsTotal = 0;
		this.iteration = 0;
	}

	@Override
	public void run() {
		// Condition to exit execution when the producer is dead and there are no
		// ingredients to consume.
		while (producer.isAlive() || !table.isEmpty()) {
			
			ns = System.nanoTime();
			// Only removes table ingredients when the chef needs those exact ones.
			if (table.hasMyIngedients(ingredient)) {
				List<Ingredient> items = table.removeAll();
				System.out.println(Thread.currentThread().getName() + " takes " + items);
				
				try {
					Thread.sleep(5);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				System.out.println(Thread.currentThread().getName() + " ate their sandwich.");
			}
			
			ns = System.nanoTime() - ns;
			nsTotal += ns;
			iteration++;
		}
		// When they are done print out a little message.
		System.out.println(Thread.currentThread().getName() + " is full.");
		System.out.println(Thread.currentThread().getName() + " took: " + nsTotal / iteration +  " ns");
	}

}
