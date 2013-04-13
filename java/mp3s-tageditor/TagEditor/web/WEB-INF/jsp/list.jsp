<%-- 
    Document   : list
    Created on : Apr 13, 2013, 5:42:09 PM
    Author     : colin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
         <link rel="stylesheet" type="text/css" href="../css/newcss.css">
        <title>List of MP3s with Missing Tags</title>
    </head>
    <body>
        <c:choose>
            <c:when test="${fn:length(tags) > 0}">
                <h1>MP3s with missing tags</h1>
                <strong>There are ${fn:length(tags)} song(s) with missing tags.</strong><br/>
                <!-- the object is 'tags': List<Map<String,Object>> -->
                <table border="0">
                    <tr>
                        <th>Title</th>
                        <th>Artist</th>
                        <th>Location</th>
                    </tr>
                    <c:forEach var="tag" items="${tags}">
                        <tr id="${tag.filehash}">
                            <td>${tag.title}</td>
                            <td>${tag.artist}</td>
                            <td>${tag.songFilepath}</td>
                        </tr>
                    </c:forEach>
                </table>
            </c:when>
            <c:otherwise>
                <h3>No MP3s have missing tags!</h3>
            </c:otherwise>
        </c:choose>
    </body>
</html>
