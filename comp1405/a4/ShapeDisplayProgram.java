import java.io.*;
import java.awt.FlowLayout;
import javax.swing.*;
import java.util.StringTokenizer;

public class ShapeDisplayProgram {
	public static final int MAX_VERTICES = 5000, MAX_FACES = 10000;
	public static int numVertices, numFaces;
	public static float[] distance;
	public static float[][] vertices;
	public static int[][] faces, facesX, facesY;

	public static void sortByXCoordinates() {
		int[] x = new int[3], y = new int[3];
		for(int i = 1; i < numFaces; i++) {
			for(int d = 0; d < 3; d++) {
				x[d] =  facesX[i][d];
				y[d] =  facesY[i][d];
			}
			float k = distance[i];
			int j = i - 1;
			while(j >= 0 && distance[j] < k) {
				for(int d = 0; d < 3; d++) {
					facesX[j + 1][d] = facesX[j][d];
					facesY[j + 1][d] = facesY[j][d];
				}
				distance[j + 1] = distance[j--];
			}
			for(int d = 0; d < 3; d++) {
				facesX[j + 1][d] = x[d];
				facesY[j + 1][d] = y[d];
			}
			distance[j + 1] = k;
		}
	}

	public static void computeProjection() {
		System.out.println("Sorting faces, please wait ...");
		distance = new float[numFaces];
		float[] x = new float[3], y = new float[3], z = new float[3];
		for(int i = 0; i < numFaces; i++) {
			for(int d = 0; d < 3; d++) {
				x[d] = (int)(vertices[faces[i][d]][0] * 700);
				y[d] = (int)(vertices[faces[i][d]][1] * 700);
				z[d] = (int)(vertices[faces[i][d]][2] * 700);
				facesX[i][d] = (int)z[d];
				facesY[i][d] = 800 - (int)y[d];
			}
			distance[i] = Math.max(x[0], Math.max(x[1], x[2]));
		}
		sortByXCoordinates();
		System.out.println("All done.");
	}

	public static void loadData(String dataFile) {
		try {
			BufferedReader in = new BufferedReader(new FileReader(dataFile));
			StringTokenizer wholeLine = new StringTokenizer(in.readLine());
			wholeLine = new StringTokenizer(in.readLine());
			numVertices = Integer.parseInt(wholeLine.nextToken());
			numFaces = Integer.parseInt(wholeLine.nextToken());
			vertices = new float[numVertices][3];
			for(int i = 0; i < numVertices; i++) {
				wholeLine = new StringTokenizer(in.readLine());
				for(int d = 0; d < 3; d++)
					vertices[i][d] = Float.parseFloat(wholeLine.nextToken());
			}
			faces = new int[numFaces][3];
			for(int i = 0; i < numFaces; i++) {
				wholeLine = new StringTokenizer(in.readLine());
				wholeLine.nextToken();
				for(int d = 0; d < 3; d++)
					faces[i][d] = Integer.parseInt(wholeLine.nextToken());
			}
			facesX = new int[numFaces][3];
			facesY = new int[numFaces][3];
			in.close();
		} catch (FileNotFoundException e) {
			System.out.println("Error: Cannot open file for reading");
			System.exit(-1);
		} catch (IOException e) {
			System.out.println("Error: Cannot read from file");
			System.exit(-1);
		}
	}

	public static void main(String [] args) {
		String fileName = JOptionPane.showInputDialog(null, "Enter 3D Model File Name (e.g., Spider)");
		loadData(fileName + ".off");
		System.out.println("Vertices: " + numVertices);
		System.out.println("Faces: " + numFaces);
		computeProjection();
		JFrame frame = new JFrame("Shape Display Program");
		frame.getContentPane().setLayout(new FlowLayout(FlowLayout.CENTER, 5, 5));
		frame.getContentPane().add(new DisplayPanel(facesX, facesY));
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.pack();
		frame.setVisible(true);
    }
}