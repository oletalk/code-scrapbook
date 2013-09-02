/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package test.oletalk.data;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetSocketAddress;

/**
 *
 * @author colin
 */
public class SocketServer {
    
    public static void main(String[] args) throws Exception
    {
        HttpServer server = HttpServer.create(new InetSocketAddress(8081), 0);
        server.createContext("/test", new MyHandler());
        server.setExecutor(null);
        server.start();
        
    }

    private static class MyHandler implements HttpHandler {

        public MyHandler() {
        }

        @Override
        public void handle(HttpExchange he) throws IOException {
            String response = "Here is the response";
            he.sendResponseHeaders(200, response.length());
            System.out.println("Request object is ");
            InputStreamReader isr = new InputStreamReader(he.getRequestBody());
            
            
            try (OutputStream os = he.getResponseBody()) {
                os.write(response.getBytes());
            }
        }
    }
}
