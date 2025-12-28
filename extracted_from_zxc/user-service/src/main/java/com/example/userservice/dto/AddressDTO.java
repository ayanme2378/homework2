package com.example.userservice.dto;

/**
 * 地址DTO
 */
public class AddressDTO {
    /**
     * 地址ID
     */
    private Long addressId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 收货人姓名
     */
    private String receiverName;

    /**
     * 电话号码
     */
    private String phone;

    /**
     * 完整地址
     */
    private String fullAddress;

    /**
     * 无参构造器
     */
    public AddressDTO() {
    }

    /**
     * 全参构造器
     */
    public AddressDTO(Long addressId, Long userId, String receiverName, String phone, String fullAddress) {
        this.addressId = addressId;
        this.userId = userId;
        this.receiverName = receiverName;
        this.phone = phone;
        this.fullAddress = fullAddress;
    }

    /**
     * Get addressId
     */
    public Long getAddressId() {
        return addressId;
    }

    /**
     * Set addressId
     */
    public void setAddressId(Long addressId) {
        this.addressId = addressId;
    }

    /**
     * Get userId
     */
    public Long getUserId() {
        return userId;
    }

    /**
     * Set userId
     */
    public void setUserId(Long userId) {
        this.userId = userId;
    }

    /**
     * Get receiverName
     */
    public String getReceiverName() {
        return receiverName;
    }

    /**
     * Set receiverName
     */
    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    /**
     * Get phone
     */
    public String getPhone() {
        return phone;
    }

    /**
     * Set phone
     */
    public void setPhone(String phone) {
        this.phone = phone;
    }

    /**
     * Get fullAddress
     */
    public String getFullAddress() {
        return fullAddress;
    }

    /**
     * Set fullAddress
     */
    public void setFullAddress(String fullAddress) {
        this.fullAddress = fullAddress;
    }

    @Override
    public String toString() {
        return "AddressDTO{" +
                "addressId=" + addressId +
                ", userId=" + userId +
                ", receiverName='" + receiverName + '\'' +
                ", phone='" + phone + '\'' +
                ", fullAddress='" + fullAddress + '\'' +
                '}';
    }
}
