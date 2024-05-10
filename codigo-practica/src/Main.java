import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.Scanner;

public class Main {
    private static final Scanner sc = new Scanner(System.in);
    private static final String path = "vector.txt";

    public static void main(String[] args) throws IOException {
        System.out.println("Please, Enter the character for separate the data");
        String separator = sc.nextLine();

        Integer[] vector = getArray(choseFile(), separator);

        sortArray(vector);

        Arrays.stream(vector).forEach(integer -> System.out.print(integer + separator));
    }

    private static void sortArray(Integer[] array) {
       for (int i = 1; i < array.length; i++) {
           Integer now = array[i];
           int j = i - 1;
           while (j >= 0 && array[j] < now) {
               array[j + 1] = array[j];
               j--;
           }
           array[j + 1] = now;
       }
    }

    private static Integer[] getArray(String input, String separator) {
        return Arrays.stream(input.split(separator))
                .map(Integer::valueOf)
                .toArray(Integer[]::new);
    }


    private static String choseFile() throws IOException {
        StringBuilder data = new StringBuilder();

        File file = new File(path);
        FileReader fr = new FileReader(file);
        BufferedReader br = new BufferedReader(fr);
        String line;

        while ((line = br.readLine()) != null) {
            data.append(line);
        }

        br.close();
        fr.close();

        return data.toString();
    }
}