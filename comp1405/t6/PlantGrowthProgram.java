public class PlantGrowthProgram {

	public static float[][] plantGrowthChange(float[][] before, float[][] after) {
		float[][] delta = new float[before.length][before[0].length];
		for(int i = 0; i < delta.length; i++) {
			for(int j = 0; j < delta[0].length; j++)
				delta[i][j] = after[i][j] - before[i][j];
		}
		return delta;
	}
	
	public static void main(String[] args) {
			
	}
}