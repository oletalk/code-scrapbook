<%-- 
    Document   : list
    Created on : Apr 13, 2013, 5:42:09 PM
    Author     : colin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>List of MP3s with Missing Tags</title>
    </head>
    <body>
        <h1>MP3s with missing tags</h1>
        <!-- the object is 'tags': List<Map<String,Object>> -->
        <c:forEach var="tag" items="${tags}">
            ${tag}<p/>
        </c:forEach>
        
    </body>
</html>
