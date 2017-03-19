/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package net.oletalk.dbexecutor.exception;

/**
 *
 * @author colin
 */
public class VersionException extends RuntimeException {
    public VersionException(String message) {
        super(message);
    }
}
