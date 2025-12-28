package com.example.addressservice.service;

import com.example.addressservice.entity.Address;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 地址服务
 */
@Service
public class AddressService {
    /**
     * 模拟地址数据
     */
    private static final Map<Long, Address> addressMap = new HashMap<>();

    static {
        addressMap.put(1L, new Address(1L, 100L, "张三", "13800000001", "北京市朝阳区某街道123号"));
        addressMap.put(2L, new Address(2L, 101L, "李四", "13800000002", "上海市浦东新区某大厦456号"));
        addressMap.put(3L, new Address(3L, 102L, "王五", "13800000003", "深圳市南山区某商厦789号"));
        addressMap.put(4L, new Address(4L, 100L, "陈六", "13800000004", "杭州市西湖区某街道321号"));
    }

    /**
     * 根据地址ID查询地址
     * @param addressId 地址ID
     * @return 地址信息
     */
    public Address getAddressById(Long addressId) {
        return addressMap.get(addressId);
    }
}
