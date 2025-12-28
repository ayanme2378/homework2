package com.example.userservice.controller;

import com.example.userservice.dto.AddressDTO;
import com.example.userservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import javax.servlet.http.HttpServletRequest;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 根据地址ID获取地址信息
     * @param addressId 地址ID
     * @return 地址信息
     */
    @GetMapping("/address/{addressId}")
    public ResponseEntity<?> getAddress(@PathVariable Long addressId, HttpServletRequest request) {
        try {
            AddressDTO address = userService.getUserAddress(addressId);
            return ResponseEntity.ok(address);
        } catch (Exception e) {
            Map<String, Object> body = new LinkedHashMap<>();
            int status = org.springframework.http.HttpStatus.NOT_FOUND.value();
            body.put("timestamp", OffsetDateTime.now(ZoneOffset.UTC).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
            body.put("status", status);
            body.put("error", org.springframework.http.HttpStatus.NOT_FOUND.getReasonPhrase());
            body.put("path", request.getRequestURI());
            return ResponseEntity.status(status).body(body);
        }
    }
}
