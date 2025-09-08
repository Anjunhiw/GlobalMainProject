package com.example.demo.mapper;
import org.apache.ibatis.annotations.Mapper;
import com.example.demo.model.LoginDTO;

@Mapper
public interface LoginMapper {

	LoginDTO selectName();
}
