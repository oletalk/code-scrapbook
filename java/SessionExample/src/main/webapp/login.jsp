<%@page contentType="text/html" pageEncoding="US-ASCII"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Login page</title>
        <meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
    </head>
    <body>
        <c:out value="${errorMsg}"/>
        <form action="/front/login" method="POST">
            Username: <input type="text" name="username">
            <br/>
            Password: <input type="password" name="password">
            <br/>
            <input type="submit" value="Login">
        </form>
    </body>
</html>
