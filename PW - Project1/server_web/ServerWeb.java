import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.GZIPOutputStream;

class Task implements Runnable {
    private final Socket clientSocket;
    public static final String CONTENT_DIR = "..\\continut";
    private static final Map<String, String> CONTENT_TYPES = new HashMap<>();

    static {
        CONTENT_TYPES.put("html", "text/html");
        CONTENT_TYPES.put("css", "text/css");
        CONTENT_TYPES.put("js", "application/javascript");
        CONTENT_TYPES.put("png", "image/png");
        CONTENT_TYPES.put("jpg", "image/jpeg");
        CONTENT_TYPES.put("jpeg", "image/jpeg");
        CONTENT_TYPES.put("gif", "image/gif");
        CONTENT_TYPES.put("ico", "image/x-icon");
        CONTENT_TYPES.put("xml", "application/xml");
    }

    public Task(Socket clientSocket) {
        this.clientSocket = clientSocket;
    }

    private String getContentType(String filename) {
        int dotIndex = filename.lastIndexOf('.');
        if (dotIndex == -1) return "application/octet-stream";
        String extension = filename.substring(dotIndex + 1).toLowerCase();
        return CONTENT_TYPES.getOrDefault(extension, "application/octet-stream");
    }

    private boolean shouldCompress(String contentType) {
        return contentType.startsWith("text/") ||
               contentType.equals("application/javascript") ||
               contentType.equals("application/json");
    }

    private byte[] compressData(byte[] data) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        try (GZIPOutputStream gzipOutputStream = new GZIPOutputStream(byteArrayOutputStream)) {
            gzipOutputStream.write(data);
        }
        return byteArrayOutputStream.toByteArray();
    }

    public void run() {
        try (
            BufferedReader socketReader = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            OutputStream outputStream = clientSocket.getOutputStream();
            PrintWriter socketWriter = new PrintWriter(new OutputStreamWriter(outputStream))
        ) {
            String firstLine = socketReader.readLine();
            if (firstLine == null) {
                clientSocket.close();
                return;
            }

            String[] requestParts = firstLine.split(" ");
            if (requestParts[1].equals("/api/utilizatori") && requestParts[0].equals("POST")) {
                int contentLength = 0;
                String line;
                while ((line = socketReader.readLine()) != null && !line.isEmpty()) {
                    if (line.toLowerCase().startsWith("content-length:")) {
                        contentLength = Integer.parseInt(line.substring(15).trim());
                    }
                }

                char[] bodyChars = new char[contentLength];
                socketReader.read(bodyChars);
                String requestBody = new String(bodyChars);

                Path userFilePath = Paths.get(CONTENT_DIR, "resurse/utilizatori.json").normalize();
                Files.write(userFilePath, requestBody.getBytes());

                String response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"status\":\"ok\"}";
                socketWriter.write(response);
                socketWriter.flush();
                clientSocket.close();
                System.out.println("[thread] POST /api/utilizatori done");
                return;
            }

            if (requestParts.length < 2 || !requestParts[0].equals("GET")) {
                sendErrorResponse(socketWriter, 400, "Bad Request");
                clientSocket.close();
                return;
            }

            String requestedPath = requestParts[1];
            if (requestedPath.contains("..")) {
                sendErrorResponse(socketWriter, 403, "Forbidden");
                clientSocket.close();
                return;
            }

            if (requestedPath.equals("/")) {
                requestedPath = "/index.html";
            }

            Path filePath = Paths.get(CONTENT_DIR, requestedPath).normalize();
            File requestedFile = filePath.toFile();

            if (!requestedFile.exists() || requestedFile.isDirectory()) {
                sendErrorResponse(socketWriter, 404, "Not Found");
                clientSocket.close();
                return;
            }

            byte[] fileContent = Files.readAllBytes(filePath);
            String contentType = getContentType(requestedFile.getName());
            boolean acceptEncoding = false;

            String line;
            while ((line = socketReader.readLine()) != null && !line.isEmpty()) {
                if (line.startsWith("Accept-Encoding:") && line.contains("gzip")) {
                    acceptEncoding = true;
                }
            }

            StringBuilder httpResponse = new StringBuilder("HTTP/1.1 200 OK\r\n");
            httpResponse.append("Content-Type: ").append(contentType).append("; charset=UTF-8\r\n");

            if (acceptEncoding && shouldCompress(contentType)) {
                byte[] compressedContent = compressData(fileContent);
                httpResponse.append("Content-Encoding: gzip\r\n");
                httpResponse.append("Content-Length: ").append(compressedContent.length).append("\r\n\r\n");
                socketWriter.write(httpResponse.toString());
                socketWriter.flush();
                outputStream.write(compressedContent);
            } else {
                httpResponse.append("Content-Length: ").append(fileContent.length).append("\r\n\r\n");
                socketWriter.write(httpResponse.toString());
                socketWriter.flush();
                outputStream.write(fileContent);
            }

            outputStream.flush();
            clientSocket.close();
            System.out.println("[Thread] request-ul a fost procesat: " + requestedPath);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void sendErrorResponse(PrintWriter writer, int statusCode, String statusText) {
        String errorResponse = "HTTP/1.1 " + statusCode + " " + statusText + "\r\n" +
                "Content-Type: text/html\r\n" +
                "Connection: close\r\n\r\n" +
                "<html><body><h1>" + statusCode + " " + statusText + "</h1></body></html>";
        writer.println(errorResponse);
    }
}

public class ServerWeb {
    static final int MAX_T = 10;
    static final int PORT = 5678;

    public static void main(String[] args) throws IOException {
        File contentDir = new File(Task.CONTENT_DIR);
        if (!contentDir.exists()) {
            System.out.println("Nu exista folderul continut!");
            return;
        }

        ExecutorService pool = Executors.newFixedThreadPool(MAX_T);
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Server-ul este activ pe portul: " + PORT);
            System.out.println("Locatie continut: " + contentDir.getAbsolutePath());

            while (true) {
                Socket clientSocket = serverSocket.accept();
                System.out.println("S-a conectat: " + clientSocket.getInetAddress());
                Task task = new Task(clientSocket);
                pool.execute(task);
            }
        }
    }
}
