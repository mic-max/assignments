import java.util.Arrays;

public class MatrixMultiplyProgram {

	public static long[][] multiply(long[][] m1, long[][] m2) {
		long[][] m3 = new long[2][2];
		m3[0][0] = m1[0][0] * m2[0][0] + m1[0][1] * m2[1][0] + m1[0][2] * m2[2][0];
		m3[0][1] = m1[0][0] * m2[0][1] + m1[0][1] * m2[1][1] + m1[0][2] * m2[2][1];
		m3[1][0] = m1[1][0] * m2[0][0] + m1[1][1] * m2[1][0] + m1[1][2] * m2[2][0];
		m3[1][1] = m1[1][0] * m2[0][1] + m1[1][1] * m2[1][1] + m1[1][2] * m2[2][1];
		return m3;
	}

	public static void main(String[] args) {
		long[][] m1 = {{1, 2, 3},{4, 5, 6}};
		long[][] m2 = {{7, 8},{9, 10},{11, 12}};
		long[][] m3 = multiply(m1, m2);
		System.out.println(Arrays.asList(m3));
	}
}