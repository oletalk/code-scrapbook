/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 *
 * @author colin
 */
// so 'EnableAutoConfiguration' didn't spot my separate controller class...
// note a lot of features depend on what you've got in your classpath e.g. jackson serialisation
@SpringBootApplication
public class Application {
    
    public static void main(String... args) throws Exception {
        SpringApplication.run(Application.class, args);
    }
}
