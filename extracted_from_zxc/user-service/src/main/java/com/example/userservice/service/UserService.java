package com.example.userservice.service;

import com.example.userservice.client.AddressServiceClient;
import com.example.userservice.dto.AddressDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 用户服务
 */
@Service
public class UserService {

    @Autowired
    private AddressServiceClient addressServiceClient;

    /**
     * 获取用户的地址信息
     * @param addressId 地址ID
     * @return 地址信息
     */
    public AddressDTO getUserAddress(Long addressId) {
        return addressServiceClient.getAddress(addressId);
    }
}
