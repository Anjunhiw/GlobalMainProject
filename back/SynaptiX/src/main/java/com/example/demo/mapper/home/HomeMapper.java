package com.example.demo.mapper.home;
import org.apache.ibatis.annotations.Mapper;
import com.example.demo.model.HomeDTO;
import java.util.List;

@Mapper
public interface HomeMapper {
    // 홈 리스트 조회
    List<HomeDTO> selectHomeList();
    // 홈 단건 조회
    HomeDTO selectHomeById(int id);
    // 홈 등록
    int insertHome(HomeDTO homeDTO);
    // 홈 수정
    int updateHome(HomeDTO homeDTO);
    // 홈 삭제
    int deleteHome(int id);
}