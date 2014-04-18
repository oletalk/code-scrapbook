<%@page contentType="text/html" pageEncoding="US-ASCII"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Welcome <c:out value="${user}"/>!</h1>
        <c:if test="${admin == true}">
            (admin)
        </c:if>
    </body>
    <form name="logout" action="/logout" method="POST">
        <input type="submit" value="Logout">
    </form>
</html>
