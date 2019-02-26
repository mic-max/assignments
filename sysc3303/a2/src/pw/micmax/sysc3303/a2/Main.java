package pw.micmax.sysc3303.a2;

import java.lang.management.*;
import java.util.*;

public class Main {

	private static final int SLEEP_TIME = 20;
	private ThreadMXBean threadMxBean = ManagementFactory.getThreadMXBean();

	private Map<String, Long> threadInitialCPU = new HashMap<>();
	private Map<String, Long> threadCPUUsage = new HashMap<>();
	private Map<String, Long> threadCurrentCPU = new HashMap<>();

	private int iteration = 0;

	public static void main(String[] args) {
		// Create the shared data structure where the Agent will add ingredients and
		// Chefs will remove.
		Table table = new Table();
		Thread producer = new Thread(new Producer(table), "Agent");

		producer.start();
		// Creates and starts Chef threads, one for each ingredient.
		for (Ingredient ingredient : Ingredient.values())
			new Thread(new Consumer(producer, table, ingredient), ingredient.toString() + " Chef").start();

//		new Main().measure();
	}

	private void measure() {
		iteration++;
		ThreadInfo[] threadInfos = threadMxBean.dumpAllThreads(false, false);
		for (ThreadInfo info : threadInfos) {
			threadInitialCPU.put(info.getThreadName(), threadMxBean.getThreadCpuTime(info.getThreadId()));
		}

		try {
			Thread.sleep(SLEEP_TIME);
		}
		catch (InterruptedException e) {
		}

		threadInfos = threadMxBean.dumpAllThreads(false, false);
		for (ThreadInfo info : threadInfos) {
			threadCurrentCPU.put(info.getThreadName(), threadMxBean.getThreadCpuTime(info.getThreadId()));
		}

		for (ThreadInfo info : threadInfos) {
			Long initialCPU = threadInitialCPU.get(info.getThreadName());
			if (initialCPU != null) {
				long elapsedCpu = threadCurrentCPU.get(info.getThreadName()) - initialCPU;
				threadCPUUsage.put(info.getThreadName(), elapsedCpu / iteration);
			}
		}

		System.out.println(threadCPUUsage);
		// Exit after printing the thread usage as to not lose the info in the
		// fast-moving console.
		System.exit(0);
	}
}
