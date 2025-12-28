package com.example.addressservice.controller;

import com.example.addressservice.entity.Address;
import com.example.addressservice.service.AddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import javax.servlet.http.HttpServletRequest;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 地址控制器
 */
@RestController
@RequestMapping("/addresses")
public class AddressController {

    @Autowired
    private AddressService addressService;

    /**
     * 根据地址ID查询单个收货地址
     * @param addressId 地址ID
     * @return 地址信息，如果不存在返回404
     */
    @GetMapping("/{addressId}")
    public ResponseEntity<?> getAddress(@PathVariable Long addressId, HttpServletRequest request) {
        Address address = addressService.getAddressById(addressId);
        if (address == null) {
            Map<String, Object> body = new LinkedHashMap<>();
            int status = HttpStatus.NOT_FOUND.value();
            body.put("timestamp", OffsetDateTime.now(ZoneOffset.UTC).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
            body.put("status", status);
            body.put("error", HttpStatus.NOT_FOUND.getReasonPhrase());
            body.put("path", request.getRequestURI());
            return ResponseEntity.status(status).body(body);
        }
        return ResponseEntity.ok(address);
    }
}
