/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.hellospringboot.exception;

/**
 *
 * @author colin
 */
public class S3Exception extends Exception {
    public S3Exception(String message) {
        super(message);
    }
}
