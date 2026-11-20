package ru.galaktika.web;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import ru.galaktika.auth.CurrentUser;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (isPublic(request) || CurrentUser.from(request) != null) {
            return true;
        }
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        return false;
    }

    private boolean isPublic(HttpServletRequest request) {
        return "OPTIONS".equals(request.getMethod())
                || ("GET".equals(request.getMethod()) && "/api/moodle/config".equals(request.getRequestURI()))
                || ("POST".equals(request.getMethod()) && "/api/session".equals(request.getRequestURI()))
                || ("POST".equals(request.getMethod())
                    && ("/api/moodle/launch".equals(request.getRequestURI())
                    || "/api/moodle/emulator/launch".equals(request.getRequestURI())));
    }
}
