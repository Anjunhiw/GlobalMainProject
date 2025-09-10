package com.example.demo.mapper;

import com.example.demo.model.UserDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
    int insertUser(UserDTO user);
    String findUserIdByEmailAndName(String email, String name);
    int verifyUserForPasswordReset(String userId, String email);
}