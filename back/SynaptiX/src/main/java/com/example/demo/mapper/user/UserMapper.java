package com.example.demo.mapper.user;

import com.example.demo.model.UserDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
    int insertUser(UserDTO user);
    String findUserIdByEmailAndBirth(String email, String birthYmd);
    int verifyUserForPasswordReset(String userId, String email, String birthYmd);
    java.util.List<UserDTO> selectAllUsers();
    UserDTO findByUserId(String userId);
    int updatePassword(String userId, String encodedPassword);
    java.util.List<UserDTO> searchUsers(java.util.Map<String, Object> params);
}