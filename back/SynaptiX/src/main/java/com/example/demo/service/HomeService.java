package com.example.demo.service;

import com.example.demo.mapper.HomeMapper;
import com.example.demo.model.HomeDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class HomeService {
    @Autowired
    private HomeMapper homeMapper;

    // 홈 리스트 조회
    public List<HomeDTO> getHomeList() {
        return homeMapper.selectHomeList();
    }

    // 홈 단건 조회
    public HomeDTO getHomeById(int id) {
        return homeMapper.selectHomeById(id);
    }

    // 홈 등록
    public int addHome(HomeDTO homeDTO) {
        return homeMapper.insertHome(homeDTO);
    }

    // 홈 수정
    public int updateHome(HomeDTO homeDTO) {
        return homeMapper.updateHome(homeDTO);
    }

    // 홈 삭제
    public int deleteHome(int id) {
        return homeMapper.deleteHome(id);
    }
}