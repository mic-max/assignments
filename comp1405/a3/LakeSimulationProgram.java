public class LakeSimulationProgram {

	private static int LIMIT = 3;
	private static int MIN_KEEP_FISH_SIZE = 10;

	public static void listFish(String[] kinds, int[] sizes) {
		for(int i = 0; i < sizes.length; i++) {
			if(sizes[i] > 0)
				System.out.println(sizes[i] + "cm " + kinds[i]);
		}
		System.out.println();
	}

	public static boolean shouldKeep(String kind, int size, int catchCount) {
		if(catchCount < LIMIT && size >= MIN_KEEP_FISH_SIZE && !kind.equals("Sunfish"))
			return true;
		return false;
	}

	public static int goFish(String[] lakeKinds, int[] lakeSizes, String[] fisherKinds, int[] fisherSizes, int fisherCount) {
		byte fish = 0;
		for(int i = 0; i < lakeSizes.length; i++) {
			if(shouldKeep(lakeKinds[i], lakeSizes[i], fisherCount)) {
				fish++;
				fisherSizes[fisherCount] = lakeSizes[i];
				fisherKinds[fisherCount++] = lakeKinds[i];
				lakeSizes[i] = 0;
				System.out.println("Caught a good one!");
			}
		}
		System.out.println();
		return fish;
	}

	public static int throwBack(String[] lakeKinds, int[] lakeSizes, String[] fisherKinds, int[] fisherSizes, int fisherCount) {
		byte fish = 0;
		int fishInLake = 0;
		for(int i = 0; i < lakeSizes.length; i++) {
			if(lakeSizes[i] != 0)
				fishInLake++;
		}
		for(int j = 0; j < lakeSizes.length && fisherCount > 0; j++) {
			if(lakeSizes[j] == 0) {
				lakeSizes[j] = fisherSizes[--fisherCount];
				lakeKinds[j] = fisherKinds[fisherCount];
				fisherSizes[fisherCount] = 0;
				fishInLake++;
				fish++;
			}
		}
		return fish;
	}

	public static void main(String[] args) {
		String[] whiteLakeFishKinds = {"Sunfish","Pickerel","Bass","Perch","Sunfish","Pickerel","Pickerel","Bass","Sunfish","Sunfish"};
		String[] silverLakeFishKinds = {"Pike","Pike","Pike"};
		String[] fredsFishKinds = new String[LIMIT];
		String[] suzysFishKinds = new String[LIMIT];
		int[] whiteLakeFishSizes = {4, 25, 20, 30, 4, 15, 9, 12, 5, 12};
		int[] silverLakeFishSizes = {35, 6, 10};
		int[] fredsFishSizes = new int[LIMIT];
		int[] suzysFishSizes = new int[LIMIT];
		int fredsFishCount = 0;
		int suzysFishCount = 0;
		System.out.println("White Lake's fish to begin:");
		listFish(whiteLakeFishKinds, whiteLakeFishSizes);
		System.out.println("Silver Lake's fish to begin:");
		listFish(silverLakeFishKinds, silverLakeFishSizes);
		System.out.println("Fred attempts to catch some fish in White Lake ...");
		fredsFishCount += goFish(whiteLakeFishKinds, whiteLakeFishSizes, fredsFishKinds, fredsFishSizes, fredsFishCount);
		System.out.println("Fred's fish now:");
		listFish(fredsFishKinds, fredsFishSizes);
		System.out.println("White Lake's fish now:");
		listFish(whiteLakeFishKinds, whiteLakeFishSizes);
		System.out.println("Suzy attempts to catch some fish in White Lake ...");
		suzysFishCount += goFish(whiteLakeFishKinds, whiteLakeFishSizes, suzysFishKinds, suzysFishSizes, suzysFishCount);
		System.out.println("Suzy's fish now:");
		listFish(suzysFishKinds, suzysFishSizes);
		System.out.println("White Lake's fish now:");
		listFish(whiteLakeFishKinds, whiteLakeFishSizes);
		System.out.println("Suzy attempts to catch some fish in Silver Lake ...");
		suzysFishCount += goFish(silverLakeFishKinds, silverLakeFishSizes, suzysFishKinds, suzysFishSizes, suzysFishCount);
		System.out.println("Suzy's fish now:");
		listFish(suzysFishKinds, suzysFishSizes);
		System.out.println("Silver Lake's fish now:");
		listFish(silverLakeFishKinds, silverLakeFishSizes);
		System.out.println("Suzy attempts to throw all of her fish into White Lake ...");
		suzysFishCount -= throwBack(whiteLakeFishKinds, whiteLakeFishSizes, suzysFishKinds, suzysFishSizes, suzysFishCount);
		System.out.println("Fred attempts to throw all of his fish into White Lake ...\n");
		fredsFishCount -= throwBack(whiteLakeFishKinds, whiteLakeFishSizes, fredsFishKinds, fredsFishSizes, fredsFishCount);
		System.out.println("Suzy's fish now:");
		listFish(suzysFishKinds, suzysFishSizes);
		System.out.println("Fred's fish now:");
		listFish(fredsFishKinds, fredsFishSizes);
		System.out.println("Silver Lake's fish now:");
		listFish(silverLakeFishKinds, silverLakeFishSizes);
		System.out.println("White Lake's fish now:");
		listFish(whiteLakeFishKinds, whiteLakeFishSizes);
	}
}