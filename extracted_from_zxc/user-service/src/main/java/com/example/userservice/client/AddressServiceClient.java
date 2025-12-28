package com.example.userservice.client;

import com.example.userservice.dto.AddressDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * 地址服务Feign客户端
 * 通过服务名称调用address-service
 */
@FeignClient(name = "address-service")
public interface AddressServiceClient {

    /**
     * 根据地址ID查询单个收货地址
     * @param addressId 地址ID
     * @return 地址信息
     */
    @GetMapping("/addresses/{addressId}")
    AddressDTO getAddress(@PathVariable("addressId") Long addressId);
}
